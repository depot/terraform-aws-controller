data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs-cluster-name
}

data "aws_ssm_parameter" "depot-token" {
  name            = var.token
  with_decryption = false
}

locals {
  service-name            = coalesce(var.service-name, "depot-controller-${var.name}")
  service-arn             = "arn:${data.aws_partition.current.partition}:ecs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:service/${var.ecs-cluster-name}/${local.service-name}"
  target-assume-role-arns = length(var.assume-role-arns) == 0 ? ["arn:${data.aws_partition.current.partition}:iam::*:role/depot-connection-*-controller"] : var.assume-role-arns
}

resource "aws_iam_role" "execution-role" {
  name = "depot-controller-${var.name}-ecs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_policy" "execution-role" {
  name = "depot-controller-${var.name}-ecs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["ssm:GetParameters"]
      Effect   = "Allow"
      Resource = data.aws_ssm_parameter.depot-token.arn
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachments_exclusive" "execution-role" {
  role_name = aws_iam_role.execution-role.name
  policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.execution-role.arn,
  ]
}

resource "aws_iam_role" "controller" {
  name = "depot-controller-${var.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_policy" "controller" {
  name = "depot-controller-${var.name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Action   = ["sts:AssumeRole"]
          Effect   = "Allow"
          Resource = local.target-assume-role-arns
        },
      ],
      var.auto-update-enabled ? tolist([
        {
          Action   = ["ecs:ListTasks", "ecs:DescribeTasks", "ecs:DescribeServices"]
          Effect   = "Allow"
          Resource = ["*"]
          Condition = {
            ArnEquals = { "ecs:cluster" = data.aws_ecs_cluster.cluster.arn }
          }
        },
      ]) : [],
      var.auto-update-enabled ? tolist([
        {
          Action   = ["ecs:UpdateService"]
          Effect   = "Allow"
          Resource = [local.service-arn]
        },
      ]) : [],
    )
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachments_exclusive" "controller" {
  role_name   = aws_iam_role.controller.name
  policy_arns = [aws_iam_policy.controller.arn]
}

resource "aws_cloudwatch_log_group" "controller" {
  name              = "depot-controller-${var.name}"
  retention_in_days = var.log-retention
  tags              = var.tags
}

resource "aws_ecs_task_definition" "controller" {
  family                   = "depot-controller-${var.name}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task-cpu
  memory                   = var.task-memory
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.execution-role.arn
  task_role_arn            = aws_iam_role.controller.arn
  tags                     = var.tags

  container_definitions = jsonencode([{
    name      = "controller"
    image     = var.controller-image
    essential = true
    environment = concat(
      [
        { name = "CLOUDD_AUTO_UPDATER_ENABLED", value = tostring(var.auto-update-enabled) },
        { name = "_CLOUDD_TOKEN_VERSION", value = tostring(data.aws_ssm_parameter.depot-token.version) },
      ],
      var.auto-update-enabled ? [
        { name = "CLOUDD_AUTO_UPDATER_CLUSTER_ARN", value = data.aws_ecs_cluster.cluster.arn },
        { name = "CLOUDD_AUTO_UPDATER_SERVICE_NAME", value = local.service-name },
      ] : [],
      var.extra-env,
    )
    secrets = [
      { name = "DEPOT_API_TOKEN", valueFrom = data.aws_ssm_parameter.depot-token.arn },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-region"        = data.aws_region.current.region
        "awslogs-group"         = aws_cloudwatch_log_group.controller.name
        "awslogs-stream-prefix" = "controller"
      }
    }
  }])
}

resource "aws_ecs_service" "controller" {
  name                               = local.service-name
  cluster                            = data.aws_ecs_cluster.cluster.arn
  task_definition                    = aws_ecs_task_definition.controller.arn
  desired_count                      = var.task-count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  availability_zone_rebalancing      = var.availability-zone-rebalancing
  propagate_tags                     = "SERVICE"
  tags                               = var.tags

  network_configuration {
    security_groups  = var.security-group-ids
    subnets          = var.subnet-ids
    assign_public_ip = var.assign-public-ip
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 0
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 0
    weight            = 100
  }
}
