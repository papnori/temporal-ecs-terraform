###############################################################
# ECR Repository Policy for Dev
###############################################################

# Retain only the last 5 images in dev
# With policy that retains only the last N images, we can push new images
# without worrying about cleaning up old images manually.
resource "aws_ecr_lifecycle_policy" "temporal_worker_dev" {
  repository = aws_ecr_repository.temporal_worker_dev.name
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Retain only last ${var.dev_lifecycle_keep_n} tagged images",
      "selection": {
        "tagStatus": "tagged",
        "tagPatternList": ["*"],
        "countType": "imageCountMoreThan",
        "countNumber": ${var.dev_lifecycle_keep_n}
      },
      "action": { "type": "expire" }
    }
  ]
}
EOF
}

