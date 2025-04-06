output "ecs_cluster_name" {
  value = aws_ecs_cluster.medusa_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.medusa_service.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.medusa_task.arn
}

