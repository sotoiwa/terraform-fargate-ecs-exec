output "private_subnet_a_id" {
  value = module.network.private_subnet_a_id
}

output "private_subnet_c_id" {
  value = module.network.private_subnet_c_id
}

output "security_group_task_id" {
  value = module.ecs.security_group_task_id
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "ecs_task_definition_arn" {
  value = module.ecs.ecs_task_definition_arn
}
