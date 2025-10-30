###########################################################################
# Local variables
###########################################################################

locals {
  vpc_nat_gateway_enabled        = true # Enable NAT Gateway for private subnets
  vpc_single_nat_gateway_enabled = true # Use a single NAT Gateway for all private subnets

  any_protocol         = "-1"
  tcp_protocol         = "tcp"
  all_ips              = "0.0.0.0/0"
  temporal_server_port = 7233 # The port that the temporal cloud or self-hosted server listens on

  # Decode the secrets from AWS Secrets Manager, as fetched by the data source below
  secrets_json = jsondecode(data.aws_secretsmanager_secret_version.sample_config.secret_string)
  secrets = {
    TEMPORAL_SERVER_ENDPOINT = local.secrets_json["TEMPORAL_SERVER_ENDPOINT"]
    TEMPORAL_SERVER_PORT     = try(tostring(local.secrets_json["TEMPORAL_SERVER_PORT"]), null)
    TEMPORAL_NAMESPACE       = local.secrets_json["TEMPORAL_NAMESPACE"]
    TEMPORAL_API_KEY         = try(sensitive(local.secrets_json["TEMPORAL_API_KEY"]), null) # Mark API key as sensitive
  }
}

###########################################################################
# Secrets Manager
###########################################################################

# Retrieve the secret from AWS Secrets Manager by name
data "aws_secretsmanager_secret" "sample_config" {
  name = "${var.env}/sample-config"
}

# Retrieve the latest version of the secret (by default, the latest is retrieved)
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

module "worker_service" {
  source = "../../modules/ecs_service"

  name        = "sample-${var.env}-temporal-worker" # will resolve to sample-dev-temporal-worker
  cluster_arn = module.cluster.ecs_cluster_arn
  cpu         = var.worker_cpu
  memory      = var.worker_memory


  container_definitions = {
    (var.worker_container_name) = {
      cpu       = var.worker_cpu
      memory    = var.worker_memory
      essential = true
      image     = var.worker_container_image # The Docker image for the temporal worker

      # Required for creating files within the container
      readonlyRootFilesystem = false

      port_mappings = [
        {
          name          = "temporal-${var.worker_container_name}"
          containerPort = local.temporal_server_port
          hostPort      = local.temporal_server_port
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
        },
        {
          name  = "BUCKET_NAME"
          value = var.s3_data_bucket_name
        }
      ]
    }
  }

  subnet_ids = module.vpc.private_subnet_ids

  security_group_egress_rules = {
    egress_all = {
      description = "Allow all outbound traffic"
      ip_protocol = local.any_protocol
      cidr_ipv4   = local.all_ips
    }
  }

  security_group_ingress_rules = {
    ingress_temporal_cloud = {
      description = "Allow traffic from Temporal cloud to worker service"
      from_port   = local.temporal_server_port
      to_port     = local.temporal_server_port
      ip_protocol = local.tcp_protocol
      cidr_ipv4   = local.all_ips
    }
  }

  # We can define autoscaling policies here with in the module, but for this example, we will define them below
  # separately for a clearer structure. So we leave this empty for now.
  autoscaling_policies = {}

}


###########################################################################
#  CloudWatch Alarms & Policy for ECS Service Autoscaling
###########################################################################


# CloudWatch alarm for high CPU utilization (scale out) -- Bursty traffic
resource "aws_cloudwatch_metric_alarm" "worker_cpu_high" {
  alarm_name          = "sample-${var.env}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = 30 # Scale out when CPU usage is above 30%
  period              = 60
  dimensions = {
    ClusterName = module.cluster.ecs_cluster_name
    ServiceName = module.worker_service.service_name
  }
  alarm_actions = [aws_appautoscaling_policy.worker_cpu_step_up.arn] # Trigger scale-out policy
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
    ClusterName = module.cluster.ecs_cluster_name
    ServiceName = module.worker_service.service_name
  }
  alarm_actions = [aws_appautoscaling_policy.worker_cpu_step_down.arn] # Trigger scale-in policy
}


# Scale out policy (add capacity) --
resource "aws_appautoscaling_policy" "worker_cpu_step_up" {
  name               = "worker-cpu-step"
  service_namespace  = "ecs"
  resource_id        = "service/${module.cluster.ecs_cluster_name}/${module.worker_service.service_name}"
  scalable_dimension = "ecs:service:DesiredCount" # We are scaling the desired count of ECS service tasks
  policy_type        = "StepScaling"
  depends_on         = [module.worker_service]

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60 # seconds before another scale action
    metric_aggregation_type = "Average"

    # Scale-out: +1 instance when CPU usage equal to or above 30% but below 40%
    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 10
      scaling_adjustment          = 1
    }

    # Scale-out: +2 instance when the alarm triggers and CPU usage is 40% or higher
    step_adjustment {
      scaling_adjustment          = 2
      metric_interval_lower_bound = 10
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

    # Scale-in: -1 instance when the alarm triggers when CPU usage is 20% or lower
    step_adjustment {
      scaling_adjustment          = -1
      metric_interval_upper_bound = 0
    }
  }
}




###########################################################################
# S3 Bucket for Application Data
###########################################################################

resource "aws_s3_bucket" "message_storage" {
  bucket = var.s3_data_bucket_name

  # NOTE: For this demo we enable force_destroy to allow easy cleanup.
  # In production, this should be kept false to prevent accidental data loss.
  force_destroy = true

}

# Add S3 access permissions to the task role
# Note: We reference the IAM role created within the ECS service module and attach the policy to it.
# We could also modify the module to accept additional policies, but for simplicity we add it here directly.
# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/5.8.1/submodules/service#input_iam_role_statements
resource "aws_iam_role_policy" "ecs_s3_access" {
  name = "s3-access-policy"
  role = module.worker_service.tasks_iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"

        ]
        Resource = [
          "arn:aws:s3:::${var.s3_data_bucket_name}",
          "arn:aws:s3:::${var.s3_data_bucket_name}/*"
        ]
      }
    ]
  })
}
