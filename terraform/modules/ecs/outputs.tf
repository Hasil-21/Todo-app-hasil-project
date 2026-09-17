output "ecs_tasks_security_group_id" {
  value = aws_security_group.ecs.id
}

output "alb_dns_name" {
  value = aws_lb.backend.dns_name
}

output "alb_arn" {
  value = aws_lb.backend.arn
}


output "cluster_name" {
  value = aws_ecs_cluster.backend.name
}

output "service_name" {
  value = aws_ecs_service.backend.name
}
