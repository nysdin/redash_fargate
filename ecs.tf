#########################################
#
# CloudWatch Log Group
#
#########################################

resource "aws_cloudwatch_log_group" "redash" {
  name              = "/ecs/fargate/redash"
  retention_in_days = 3
}

#########################################
#
# ECS Cluster
#
#########################################

resource "aws_ecs_cluster" "redash" {
  name = "redash-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "redash" {
  cluster_name       = aws_ecs_cluster.redash.name
  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 1
  }
}

#########################################
#
# ECS Service
#
#########################################

resource "aws_ecs_service" "redash" {
  name                    = "redash"
  cluster                 = aws_ecs_cluster.redash.arn
  desired_count           = 1
  enable_ecs_managed_tags = true
  enable_execute_command  = true
  launch_type             = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.redash_blue_target_group.arn
    container_name   = "server"
    container_port   = 5000
  }
  network_configuration {
    subnets = [
      aws_subnet.public_1a.id,
      aws_subnet.public_1c.id
    ]
    security_groups  = [aws_security_group.redash.id]
    assign_public_ip = true
  }
  platform_version = "LATEST"
  propagate_tags   = "SERVICE"
  task_definition  = aws_ecs_task_definition.redash.arn

  lifecycle {
    ignore_changes = [
      desired_count,
      # task_definition, <= blue green deploymentの時は外す。
    ]
  }
}

resource "aws_ecs_service" "redash_scheduler" {
  name                    = "redash-scheduler"
  cluster                 = aws_ecs_cluster.redash.arn
  desired_count           = 1
  enable_ecs_managed_tags = true
  enable_execute_command  = true
  launch_type             = "FARGATE"
  network_configuration {
    subnets = [
      aws_subnet.public_1a.id,
      aws_subnet.public_1c.id
    ]
    security_groups  = [aws_security_group.redash.id]
    assign_public_ip = true
  }
  platform_version = "1.4.0"
  propagate_tags   = "SERVICE"
  task_definition  = aws_ecs_task_definition.redash_scheduler.arn

  lifecycle {
    ignore_changes = [
      desired_count,
      # task_definition,
    ]
  }
}

#########################################
#
# Task Definition
#
#########################################
resource "aws_ecs_task_definition" "redash" {
  family                   = "redash"
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.redash_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.redash_ecs_task_role.arn

  container_definitions = templatefile(
    "templates/container_definitions/redash.json.tpl",
    {
      awslogs_group               = aws_cloudwatch_log_group.redash.name
      redash_database_url_ssm_arn = aws_ssm_parameter.redash_postgresql_url.arn
      redash_redis_url_ssm_arn    = aws_ssm_parameter.redash_redis_url.arn
      redash_redis_url_ssm_arn    = aws_ssm_parameter.redash_redis_url.arn
      mackerel_apikey_ssm_arn     = aws_ssm_parameter.mackerel_apikey.arn
    }
  )
}

resource "aws_ecs_task_definition" "redash_scheduler" {
  family                   = "redash-scheduler"
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.redash_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.redash_ecs_task_role.arn

  container_definitions = templatefile(
    "templates/container_definitions/redash_scheduler.json.tpl",
    {
      awslogs_group               = aws_cloudwatch_log_group.redash.name
      redash_database_url_ssm_arn = aws_ssm_parameter.redash_postgresql_url.arn
      redash_redis_url_ssm_arn    = aws_ssm_parameter.redash_redis_url.arn
    }
  )
}

# redash用のDBを初期化するためにrun taskする一度きりのタスク定義
resource "aws_ecs_task_definition" "redash_create_db" {
  family                   = "redash_create_db"
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.redash_ecs_task_execution_role.arn

  container_definitions = templatefile(
    "./templates/container_definitions/redash_create_db.json.tpl",
    {
      awslogs_group               = aws_cloudwatch_log_group.redash.name
      redash_database_url_ssm_arn = aws_ssm_parameter.redash_postgresql_url.arn
      redash_redis_url_ssm_arn    = aws_ssm_parameter.redash_redis_url.arn
    }
  )
}
