output "service-name" {
  value       = aws_ecs_service.cloudd.name
  description = "Name of the cloudd ECS service."
}

output "task-role-arn" {
  value       = aws_iam_role.cloudd.arn
  description = "ARN of the cloudd task role."
}

output "execution-role-arn" {
  value       = aws_iam_role.execution-role.arn
  description = "ARN of the cloudd ECS execution role."
}

output "log-group-name" {
  value       = aws_cloudwatch_log_group.cloudd.name
  description = "CloudWatch log group name for cloudd."
}

output "token" {
  value       = var.token
  description = "SSM parameter name used as DEPOT_API_TOKEN for cloudd."
}
