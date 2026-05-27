output "service-name" {
  value       = aws_ecs_service.controller.name
  description = "Name of the Depot controller ECS service."
}

output "task-role-arn" {
  value       = aws_iam_role.controller.arn
  description = "ARN of the Depot controller task role."
}

output "execution-role-arn" {
  value       = aws_iam_role.execution-role.arn
  description = "ARN of the Depot controller ECS execution role."
}

output "log-group-name" {
  value       = aws_cloudwatch_log_group.controller.name
  description = "CloudWatch log group name for the Depot controller."
}

output "token" {
  value       = var.token
  description = "SSM parameter name used as DEPOT_API_TOKEN for the Depot controller."
}
