// -------------------------------------------------------------
// Cluster
// -------------------------------------------------------------

module "cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "6.6.1"


  name = var.cluster_name

  # The default capacity provider strategy uses a weighted distribution:
  # - Prefer FARGATE_SPOT (weight = 4) to maximize cost savings (when Spot capacity is available)
  # - Use FARGATE (weight = 1) as a fallback to ensure availability
  #
  # ECS will attempt to launch tasks using this ratio unless a service explicitly overrides
  # it with its own capacity provider strategy.
  # https://aws.amazon.com/awstv/watch/a30119192a0/
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 1
      # base   = 1 # Optionally, you can set a base of 1 to ensure at least one FARGATE task is always running
    }
    FARGATE_SPOT = {
      weight = 4
    }
  }

  create_cloudwatch_log_group            = true
  cloudwatch_log_group_name              = "/ecs/${var.cluster_name}"
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_class             = var.cloudwatch_log_group_class

  tags = var.tags
}
