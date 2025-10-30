module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "6.6.1"

  name        = var.name
  cluster_arn = var.cluster_arn

  cpu    = var.cpu
  memory = var.memory

  launch_type = var.launch_type

  container_definitions  = var.container_definitions
  enable_execute_command = true

  subnet_ids                   = var.subnet_ids
  security_group_ingress_rules = var.security_group_ingress_rules
  security_group_egress_rules  = var.security_group_egress_rules

  network_mode = var.network_mode

  # Autoscaling configuration
  autoscaling_max_capacity = var.autoscaling_max_capacity
  autoscaling_min_capacity = var.autoscaling_min_capacity
  autoscaling_policies     = var.autoscaling_policies

  tags = var.tags
}
