output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = module.cluster.name

}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  value       = module.cluster.arn
}


output "ecs_cluster_id" {
  description = "The ID of the ECS cluster."
  value       = module.cluster.id
}

