# depot/controller/aws

Runs one controller ECS service for Depot Managed.

```tf
module "controller" {
  source  = "depot/controller/aws"
  version = "x.x.x"

  name               = "acme"
  token              = "/depot/cloudd/acme-token"
  ecs-cluster-name   = "cluster"
  subnet-ids         = ["subnet-abc123", "subnet-def456"]
  security-group-ids = ["sg-abc123"]
}
```

This module starts the controller service only. It expects:

- a Depot controller token to already be stored in SSM Parameter Store
- an ECS cluster, subnets, and security group to already exist

For customer-managed controllers, create the token from the Depot organization
settings page and store it in SSM under the value passed to `token`.

By default, the task role can assume target account roles matching:

```text
arn:aws:iam::*:role/depot-connection-*-control-plane
```

Pass `assume-role-arns` when the controller should be restricted to a narrower set of
target connection role ARNs.

## Auto-update behavior

Auto-update is enabled by default. When Depot reports a newer active controller
version, the controller asks ECS to force a new deployment of this service. This lets
ECS resolve mutable image tags, such as `ghcr.io/depot/cloudd:main`, to fresh
image digests for the new deployment.

This only upgrades automatically when `controller-image` uses a mutable tag. If the
image is pinned to a digest, ECS will keep deploying that digest until Terraform
or another external release process updates the task definition image.

Set `auto-update-enabled = false` for customer-hosted or high-compliance
installations that manage upgrades externally. In that mode, the module sets
`CLOUDD_AUTO_UPDATER_ENABLED=false`, omits the
`CLOUDD_AUTO_UPDATER_CLUSTER_ARN` and `CLOUDD_AUTO_UPDATER_SERVICE_NAME`
environment variables, and does not grant the controller ECS update permissions.

<!-- BEGIN_TF_DOCS -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input_name) | Name used to namespace AWS resources for this controller. | `string` | n/a | yes |
| <a name="input_security-group-ids"></a> [security-group-ids](#input_security-group-ids) | Existing security group IDs for the controller ECS service. | `list(string)` | n/a | yes |
| <a name="input_subnet-ids"></a> [subnet-ids](#input_subnet-ids) | Existing subnet IDs for the controller ECS service. | `list(string)` | n/a | yes |
| <a name="input_token"></a> [token](#input_token) | SSM parameter name containing DEPOT_API_TOKEN for the controller. | `string` | n/a | yes |
| <a name="input_assign-public-ip"></a> [assign-public-ip](#input_assign-public-ip) | Whether ECS should assign public IPs to controller tasks. | `bool` | `true` | no |
| <a name="input_assume-role-arns"></a> [assume-role-arns](#input_assume-role-arns) | Target account role ARNs the controller may assume. Defaults to the standard Depot connection control-plane role name in any account. | `list(string)` | `[]` | no |
| <a name="input_availability-zone-rebalancing"></a> [availability-zone-rebalancing](#input_availability-zone-rebalancing) | Availability zone rebalancing setting for the ECS service. | `string` | `"ENABLED"` | no |
| <a name="input_auto-update-enabled"></a> [auto-update-enabled](#input_auto-update-enabled) | Whether the controller should force a new ECS service deployment when Depot reports a newer active controller version. | `bool` | `true` | no |
| <a name="input_controller-image"></a> [controller-image](#input_controller-image) | Container image to run for the controller. | `string` | `"ghcr.io/depot/cloudd:main"` | no |
| <a name="input_ecs-cluster-name"></a> [ecs-cluster-name](#input_ecs-cluster-name) | Existing ECS cluster name where the controller should run. | `string` | `"cluster"` | no |
| <a name="input_extra-env"></a> [extra-env](#input_extra-env) | Extra environment variables for the controller. | `list(object({ name = string, value = string }))` | `[]` | no |
| <a name="input_log-retention"></a> [log-retention](#input_log-retention) | Number of days to keep CloudWatch logs for the controller. | `number` | `30` | no |
| <a name="input_service-name"></a> [service-name](#input_service-name) | ECS service name. Defaults to depot-controller-<name>. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input_tags) | A map of tags to apply to supported resources. | `map(string)` | `{}` | no |
| <a name="input_task-count"></a> [task-count](#input_task-count) | Desired count of controller tasks. | `number` | `1` | no |
| <a name="input_task-cpu"></a> [task-cpu](#input_task-cpu) | CPU units for the controller Fargate task. | `number` | `1024` | no |
| <a name="input_task-memory"></a> [task-memory](#input_task-memory) | Memory in MiB for the controller Fargate task. | `number` | `2048` | no |

## Outputs

| Name | Description | Value | Sensitive |
|------|-------------|-------|:---------:|
| <a name="output_execution-role-arn"></a> [execution-role-arn](#output_execution-role-arn) | ARN of the controller ECS execution role. | `"arn:aws:iam::123456789012:role/depot-controller-acme-ecs"` | no |
| <a name="output_log-group-name"></a> [log-group-name](#output_log-group-name) | CloudWatch log group name for the controller. | `"depot-controller-acme"` | no |
| <a name="output_service-name"></a> [service-name](#output_service-name) | Name of the controller ECS service. | `"depot-controller-acme"` | no |
| <a name="output_task-role-arn"></a> [task-role-arn](#output_task-role-arn) | ARN of the controller task role. | `"arn:aws:iam::123456789012:role/depot-controller-acme"` | no |
| <a name="output_token"></a> [token](#output_token) | SSM parameter name used as DEPOT_API_TOKEN for the controller. | `"/depot/cloudd/acme-token"` | no |

<!-- END_TF_DOCS -->
