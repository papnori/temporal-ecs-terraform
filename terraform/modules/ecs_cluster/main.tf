// -------------------------------------------------------------
// Cluster
// -------------------------------------------------------------

module "cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.12.1"


  cluster_name = var.cluster_name

  # The default capacity provider strategy uses a weighted distribution:
  # - FARGATE_SPOT is preferred (weight = 2) to save costs
  # - FARGATE is included (weight = 1) to ensure some task reliability
  #
  # ECS will attempt to launch tasks using this ratio unless a service
  # explicitly overrides it with its own capacity provider strategy.
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 1
      }
    }

    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 2
      }
    }
  }

  create_cloudwatch_log_group            = true
  cloudwatch_log_group_name              = "/ecs/${var.cluster_name}"
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  tags = var.tags
}
