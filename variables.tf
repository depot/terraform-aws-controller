// Required

variable "name" {
  type        = string
  description = "Name used to namespace AWS resources for this Depot controller."
}

variable "token" {
  type        = string
  description = "SSM parameter name containing DEPOT_API_TOKEN for the Depot controller."
}

variable "token-kms-key-arn" {
  type        = string
  description = "Customer-managed KMS key ARN used to encrypt the DEPOT_API_TOKEN SecureString parameter. Leave null when using the AWS-managed SSM key."
  default     = null
}

variable "subnet-ids" {
  type        = list(string)
  description = "Existing subnet IDs for the Depot controller ECS service."
}

variable "security-group-ids" {
  type        = list(string)
  description = "Existing security group IDs for the Depot controller ECS service."
}

// Optional

variable "ecs-cluster-name" {
  type        = string
  description = "Existing ECS cluster name where the Depot controller should run."
  default     = "cluster"
}

variable "service-name" {
  type        = string
  description = "ECS service name. Defaults to depot-controller-<name>."
  default     = null
}

variable "controller-image" {
  type        = string
  description = "Container image to run for the Depot controller."
  default     = "ghcr.io/depot/cloudd:stable"
}

variable "auto-update-enabled" {
  type        = bool
  description = "Whether the Depot controller should force a new ECS service deployment when Depot reports a newer active Depot controller version."
  default     = true
}

variable "auto-update-channel" {
  type        = string
  description = "Depot controller release channel to use for auto-update checks."
  default     = "stable"

  validation {
    condition     = contains(["main", "stable"], var.auto-update-channel)
    error_message = "auto-update-channel must be either main or stable."
  }
}

variable "task-count" {
  type        = number
  description = "Desired count of Depot controller tasks."
  default     = 1
}

variable "task-cpu" {
  type        = number
  description = "CPU units for the Depot controller Fargate task."
  default     = 1024
}

variable "task-memory" {
  type        = number
  description = "Memory in MiB for the Depot controller Fargate task."
  default     = 2048
}

variable "log-retention" {
  type        = number
  description = "Number of days to keep CloudWatch logs for the Depot controller."
  default     = 30
}

variable "assign-public-ip" {
  type        = bool
  description = "Whether ECS should assign public IPs to Depot controller tasks."
  default     = true
}

variable "availability-zone-rebalancing" {
  type        = string
  description = "Availability zone rebalancing setting for the ECS service."
  default     = "ENABLED"
}

variable "assume-role-arns" {
  type        = list(string)
  description = "Target account role ARNs the Depot controller may assume. Defaults to the standard Depot connection controller role name in any account."
  default     = []
}

variable "extra-env" {
  type        = list(object({ name = string, value = string }))
  description = "Extra environment variables for the Depot controller."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to supported resources."
  default     = {}
}
