module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.12.1"

  name        = var.name
  cluster_arn = var.cluster_arn

  cpu    = var.cpu
  memory = var.memory

  launch_type = var.launch_type

  container_definitions  = var.container_definitions
  enable_execute_command = true

  subnet_ids           = var.subnet_ids
  security_group_rules = var.security_group_rules
  network_mode         = var.network_mode


  # Explicitly define task role permissions
  task_exec_iam_statements = {
    s3access = {
      effect = "Allow",
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      resources = ["arn:aws:s3:::*"]
    }
  }

  # Autoscaling configuration
  autoscaling_max_capacity = var.autoscaling_max_capacity
  # desired_count            = var.autoscaling_min_capacity
  autoscaling_min_capacity = var.autoscaling_min_capacity
  autoscaling_policies     = var.autoscaling_policies

  tags = var.tags
}
