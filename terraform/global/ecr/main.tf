########################################################################
# ECR Repositories for Dev
########################################################################

# Temporal Worker repository for Dev
resource "aws_ecr_repository" "temporal_worker_dev" {
  name                 = "temporal-worker-dev"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
