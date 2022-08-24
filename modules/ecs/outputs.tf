output "security_group_task_id" {
  value = aws_security_group.this.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}
