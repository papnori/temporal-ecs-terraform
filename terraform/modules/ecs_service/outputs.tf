output "service_name" {
  description = "The name of the ECS service."
  value       = module.ecs_service.name
}


output "id" {
  description = "The ID of the ECS service."
  value       = module.ecs_service.id

}


output "task_definition_arn" {
  description = "The ARN of the ECS task definition."
  value       = module.ecs_service.task_definition_arn

}

output "security_group_id" {
  description = "The security group ID of the ECS service."
  value       = module.ecs_service.security_group_id
}


output "task_role_name" {
  description = "The name of the ECS task role."
  value       = module.ecs_service.tasks_iam_role_name
}