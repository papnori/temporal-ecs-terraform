output "temporal_worker_dev_repository_url" {
  description = "ECR repository URL for Temporal Worker dev"
  value       = aws_ecr_repository.temporal_worker_dev.repository_url
}