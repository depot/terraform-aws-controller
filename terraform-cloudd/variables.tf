// Required

variable "name" {
  type        = string
  description = "Name used to namespace AWS resources for this cloudd agent."
}

variable "token" {
  type        = string
  description = "SSM parameter name containing DEPOT_API_TOKEN for cloudd."
}

variable "subnet-ids" {
  type        = list(string)
  description = "Existing subnet IDs for the cloudd ECS service."
}

variable "security-group-ids" {
  type        = list(string)
  description = "Existing security group IDs for the cloudd ECS service."
}

// Optional

variable "ecs-cluster-name" {
  type        = string
  description = "Existing ECS cluster name where cloudd should run."
  default     = "cluster"
}

variable "service-name" {
  type        = string
  description = "ECS service name. Defaults to depot-cloudd-<name>."
  default     = null
}

variable "cloudd-image" {
  type        = string
  description = "Container image to run for cloudd."
  default     = "ghcr.io/depot/cloudd:main"
}

variable "task-count" {
  type        = number
  description = "Desired count of cloudd tasks."
  default     = 1
}

variable "task-cpu" {
  type        = number
  description = "CPU units for the cloudd Fargate task."
  default     = 1024
}

variable "task-memory" {
  type        = number
  description = "Memory in MiB for the cloudd Fargate task."
  default     = 2048
}

variable "log-retention" {
  type        = number
  description = "Number of days to keep CloudWatch logs for cloudd."
  default     = 30
}

variable "assign-public-ip" {
  type        = bool
  description = "Whether ECS should assign public IPs to cloudd tasks."
  default     = true
}

variable "availability-zone-rebalancing" {
  type        = string
  description = "Availability zone rebalancing setting for the ECS service."
  default     = "ENABLED"
}

variable "assume-role-arns" {
  type        = list(string)
  description = "Target account role ARNs cloudd may assume. Defaults to the standard Depot connection control-plane role name in any account."
  default     = []
}

variable "extra-env" {
  type        = list(object({ name = string, value = string }))
  description = "Extra environment variables for cloudd."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to supported resources."
  default     = {}
}
