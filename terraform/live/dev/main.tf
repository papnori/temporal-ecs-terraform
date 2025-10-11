###########################################################################
# Local variables
###########################################################################

locals {
  vpc_nat_gateway_enabled        = true # Enable NAT Gateway for private subnets
  vpc_single_nat_gateway_enabled = true # Use a single NAT Gateway for all private subnets

  http_port      = 80
  https_port     = 443
  any_port       = 0
  any_protocol   = "-1"
  tcp_protocol   = "tcp"
  https_protocol = "HTTPS"
  http_protocol  = "HTTP"
  all_ips        = "0.0.0.0/0"

  temporal_server_port = 7233 # The port that the temporal cloud listens on
  health_check_port    = 8080 # The port that the health check endpoint listens on

  # Fetch secrets from AWS Secrets Manager
  secrets_json = jsondecode(data.aws_secretsmanager_secret_version.sample_config.secret_string)
  secrets = {
    TEMPORAL_SERVER_ENDPOINT = local.secrets_json["TEMPORAL_SERVER_ENDPOINT"]
    TEMPORAL_SERVER_PORT     = tostring(local.secrets_json["TEMPORAL_SERVER_PORT"])
    TEMPORAL_NAMESPACE       = local.secrets_json["TEMPORAL_NAMESPACE"]
    TEMPORAL_API_KEY         = local.secrets_json["TEMPORAL_API_KEY"]
  }

}

###########################################################################
# Secrets Manager
###########################################################################

data "aws_secretsmanager_secret" "sample_config" {
  name = "${var.env}/sample-config"
}

data "aws_secretsmanager_secret_version" "sample_config" {
  secret_id = data.aws_secretsmanager_secret.sample_config.id
}


###########################################################################
# VPC and Networking
###########################################################################

module "vpc" {
  source = "../../modules/network"

  name                      = "sample-${var.env}-vpc" # will resolve to sample-dev-vpc
  cidr                      = var.vpc_cidr            # CIDR block for the VPC
  azs                       = var.vpc_availability_zones
  private_subnets           = var.vpc_private_subnets
  public_subnets            = var.vpc_public_subnets
  enable_nat_gateway        = local.vpc_nat_gateway_enabled
  enable_single_nat_gateway = local.vpc_single_nat_gateway_enabled


  vpc_endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.private_route_table_ids])
    }
  }

  tags = {
    VPC = "sample-${var.env}"
  }
}


###############################################################################
# ECS Cluster
###############################################################################


module "cluster" {
  source       = "../../modules/ecs_cluster"
  cluster_name = "sample-${var.env}-cluster" # will resolve to sample-dev-cluster

  cloudwatch_log_group_retention_in_days = var.ecs_cluster_cloudwatch_log_group_retention_in_days

  tags = {
    Name = "sample-${var.env}-cluster"
  }
}


###############################################################################
# ECS Task Definition for the Temporal Workers
###############################################################################

# CloudWatch alarm for high CPU utilization (scale out)
resource "aws_cloudwatch_metric_alarm" "worker_cpu_high" {
  alarm_name          = "sample-${var.env}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 30 # Scale out when CPU usage is above 30%
  period              = 60
  dimensions = {
    ClusterName = "sample-${var.env}-cluster"
    ServiceName = "sample-${var.env}-temporal-worker"
  }
  alarm_actions = [aws_appautoscaling_policy.worker_cpu_step_up.arn]
}

# CloudWatch alarm for low CPU utilization (scale in)
resource "aws_cloudwatch_metric_alarm" "worker_cpu_low" {
  alarm_name          = "sample-${var.env}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 10 # Require sustained low CPU before scaling in
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 20 # Scale in when CPU usage is below 20%
  period              = 60
  dimensions = {
    ClusterName = "sample-${var.env}-cluster"
    ServiceName = "sample-${var.env}-temporal-worker"
  }
  alarm_actions = [aws_appautoscaling_policy.worker_cpu_step_down.arn]
}

# Scale out policy (add capacity)
resource "aws_appautoscaling_policy" "worker_cpu_step_up" {
  name               = "worker-cpu-step"
  service_namespace  = "ecs"
  resource_id        = "service/${module.cluster.ecs_cluster_name}/sample-${var.env}-temporal-worker"
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "StepScaling"
  depends_on         = [module.worker_service]

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60 # seconds before another scale action
    metric_aggregation_type = "Average"

    # Scale-out: +1 instance when the alarm triggers
    step_adjustment {
      scaling_adjustment          = 2
      metric_interval_lower_bound = 0
    }
  }
}

# Scale in policy (remove capacity)
resource "aws_appautoscaling_policy" "worker_cpu_step_down" {
  name               = "worker-cpu-step-down"
  service_namespace  = "ecs"
  resource_id        = "service/${module.cluster.ecs_cluster_name}/sample-${var.env}-temporal-worker"
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "StepScaling"
  depends_on         = [module.worker_service]

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300 # 5 minutes cooldown for scaling in (more conservative)
    metric_aggregation_type = "Average"

    # Scale-in: -1 instance when the alarm triggers
    step_adjustment {
      scaling_adjustment          = -1
      metric_interval_upper_bound = 0
    }
  }
}

module "worker_service" {
  source = "../../modules/ecs_service"

  name        = "sample-${var.env}-temporal-worker" # will resolve to sample-dev-temporal-worker
  cluster_arn = module.cluster.ecs_cluster_arn
  cpu         = var.worker_cpu
  memory      = var.worker_memory

  autoscaling_policies = {}

  container_definitions = {
    (var.worker_container_name) = {
      cpu       = var.worker_cpu
      memory    = var.worker_memory
      essential = true
      image     = var.worker_container_image # The Docker image for the temporal worker

      # Required for the file downloads
      readonly_root_filesystem = false

      port_mappings = [
        {
          name          = "temporal-${var.worker_container_name}"
          containerPort = local.temporal_server_port
          hostPort      = local.temporal_server_port
          protocol      = local.tcp_protocol
        },
        {
          name          = "health-check-${var.worker_container_name}"
          containerPort = local.health_check_port
          hostPort      = local.health_check_port
          protocol      = local.tcp_protocol
        }
      ]

      # container-specific environment variables
      environment = [
        {
          name  = "TEMPORAL_SERVER_ENDPOINT"
          value = local.secrets.TEMPORAL_SERVER_ENDPOINT
        },
        {
          name  = "TEMPORAL_SERVER_PORT"
          value = local.secrets.TEMPORAL_SERVER_PORT
        },
        {
          name  = "TEMPORAL_NAMESPACE"
          value = local.secrets.TEMPORAL_NAMESPACE
        },
        {
          name  = "TEMPORAL_API_KEY"
          value = local.secrets.TEMPORAL_API_KEY
        }
      ]
    }
  }

  subnet_ids = module.vpc.private_subnet_ids

  security_group_rules = {
    egress_all = {
      type        = "egress"
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_temporal_cloud = {
      type        = "ingress"
      from_port   = local.temporal_server_port
      to_port     = local.temporal_server_port
      description = "Allow traffic from Temporal cloud to worker service"
      protocol    = local.any_protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

###########################################################################
# S3 Bucket for Application Data
###########################################################################

resource "aws_s3_bucket" "message_storage" {
  bucket = "my-little-sample-message-storage-dev"

  tags = {
    Name        = "Message Storage Bucket"
    Environment = var.env
    Project     = "Sample"
  }
}

resource "aws_s3_bucket_versioning" "message_storage" {
  bucket = aws_s3_bucket.message_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "message_storage" {
  bucket = aws_s3_bucket.message_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
