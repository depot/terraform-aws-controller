# depot/cloudd/aws

Runs one `cloudd` reconciler ECS service for Depot Managed.

```tf
module "cloudd" {
  source  = "depot/cloudd/aws"
  version = "x.x.x"

  name               = "acme"
  token              = "/depot/cloudd/acme-token"
  ecs-cluster-name   = "cluster"
  subnet-ids         = ["subnet-abc123", "subnet-def456"]
  security-group-ids = ["sg-abc123"]
}
```

This module starts the reconciler service only. It expects:

- a Depot cloudd agent token to already be stored in SSM Parameter Store
- an ECS cluster, subnets, and security group to already exist

For customer-managed agents, create the token from the Depot organization
settings page and store it in SSM under the value passed to `token`.

By default, the task role can assume target account roles matching:

```text
arn:aws:iam::*:role/depot-connection-*-control-plane
```

Pass `assume-role-arns` when the agent should be restricted to a narrower set of
target connection role ARNs.

<!-- BEGIN_TF_DOCS -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input_name) | Name used to namespace AWS resources for this cloudd agent. | `string` | n/a | yes |
| <a name="input_security-group-ids"></a> [security-group-ids](#input_security-group-ids) | Existing security group IDs for the cloudd ECS service. | `list(string)` | n/a | yes |
| <a name="input_subnet-ids"></a> [subnet-ids](#input_subnet-ids) | Existing subnet IDs for the cloudd ECS service. | `list(string)` | n/a | yes |
| <a name="input_token"></a> [token](#input_token) | SSM parameter name containing DEPOT_API_TOKEN for cloudd. | `string` | n/a | yes |
| <a name="input_assign-public-ip"></a> [assign-public-ip](#input_assign-public-ip) | Whether ECS should assign public IPs to cloudd tasks. | `bool` | `true` | no |
| <a name="input_assume-role-arns"></a> [assume-role-arns](#input_assume-role-arns) | Target account role ARNs cloudd may assume. Defaults to the standard Depot connection control-plane role name in any account. | `list(string)` | `[]` | no |
| <a name="input_availability-zone-rebalancing"></a> [availability-zone-rebalancing](#input_availability-zone-rebalancing) | Availability zone rebalancing setting for the ECS service. | `string` | `"ENABLED"` | no |
| <a name="input_cloudd-image"></a> [cloudd-image](#input_cloudd-image) | Container image to run for cloudd. | `string` | `"ghcr.io/depot/cloudd:main"` | no |
| <a name="input_ecs-cluster-name"></a> [ecs-cluster-name](#input_ecs-cluster-name) | Existing ECS cluster name where cloudd should run. | `string` | `"cluster"` | no |
| <a name="input_extra-env"></a> [extra-env](#input_extra-env) | Extra environment variables for cloudd. | `list(object({ name = string, value = string }))` | `[]` | no |
| <a name="input_log-retention"></a> [log-retention](#input_log-retention) | Number of days to keep CloudWatch logs for cloudd. | `number` | `30` | no |
| <a name="input_service-name"></a> [service-name](#input_service-name) | ECS service name. Defaults to depot-cloudd-<name>. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input_tags) | A map of tags to apply to supported resources. | `map(string)` | `{}` | no |
| <a name="input_task-count"></a> [task-count](#input_task-count) | Desired count of cloudd tasks. | `number` | `1` | no |
| <a name="input_task-cpu"></a> [task-cpu](#input_task-cpu) | CPU units for the cloudd Fargate task. | `number` | `1024` | no |
| <a name="input_task-memory"></a> [task-memory](#input_task-memory) | Memory in MiB for the cloudd Fargate task. | `number` | `2048` | no |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_execution-role-arn"></a> [execution-role-arn](#output_execution-role-arn) | ARN of the cloudd ECS execution role. | `"arn:aws:iam::123456789012:role/depot-cloudd-acme-ecs"` | no |
| <a name="output_log-group-name"></a> [log-group-name](#output_log-group-name) | CloudWatch log group name for cloudd. | `"depot-cloudd-acme"` | no |
| <a name="output_service-name"></a> [service-name](#output_service-name) | Name of the cloudd ECS service. | `"depot-cloudd-acme"` | no |
| <a name="output_task-role-arn"></a> [task-role-arn](#output_task-role-arn) | ARN of the cloudd task role. | `"arn:aws:iam::123456789012:role/depot-cloudd-acme"` | no |
| <a name="output_token"></a> [token](#output_token) | SSM parameter name used as DEPOT_API_TOKEN for cloudd. | `"/depot/cloudd/acme-token"` | no |

<!-- END_TF_DOCS -->
