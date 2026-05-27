// Required

variable "name" {
  type        = string
  description = "Name used to namespace AWS resources for this controller."
}

variable "token" {
  type        = string
  description = "SSM parameter name containing DEPOT_API_TOKEN for the controller."
}

variable "subnet-ids" {
  type        = list(string)
  description = "Existing subnet IDs for the controller ECS service."
}

variable "security-group-ids" {
  type        = list(string)
  description = "Existing security group IDs for the controller ECS service."
}

// Optional

variable "ecs-cluster-name" {
  type        = string
  description = "Existing ECS cluster name where the controller should run."
  default     = "cluster"
}

variable "service-name" {
  type        = string
  description = "ECS service name. Defaults to depot-controller-<name>."
  default     = null
}

variable "controller-image" {
  type        = string
  description = "Container image to run for the controller."
  default     = "ghcr.io/depot/cloudd:main"
}

variable "auto-update-enabled" {
  type        = bool
  description = "Whether the controller should force a new ECS service deployment when Depot reports a newer active controller version."
  default     = true
}

variable "task-count" {
  type        = number
  description = "Desired count of controller tasks."
  default     = 1
}

variable "task-cpu" {
  type        = number
  description = "CPU units for the controller Fargate task."
  default     = 1024
}

variable "task-memory" {
  type        = number
  description = "Memory in MiB for the controller Fargate task."
  default     = 2048
}

variable "log-retention" {
  type        = number
  description = "Number of days to keep CloudWatch logs for the controller."
  default     = 30
}

variable "assign-public-ip" {
  type        = bool
  description = "Whether ECS should assign public IPs to controller tasks."
  default     = true
}

variable "availability-zone-rebalancing" {
  type        = string
  description = "Availability zone rebalancing setting for the ECS service."
  default     = "ENABLED"
}

variable "assume-role-arns" {
  type        = list(string)
  description = "Target account role ARNs the controller may assume. Defaults to the standard Depot connection control-plane role name in any account."
  default     = []
}

variable "extra-env" {
  type        = list(object({ name = string, value = string }))
  description = "Extra environment variables for the controller."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to supported resources."
  default     = {}
}
