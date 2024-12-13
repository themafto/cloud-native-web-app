# IAM Role для ECS задач
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Sid    = "",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
    }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = local.policy_arn # Политика для выполнения задач
}

#ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "main-esc-cluster"
}
resource "aws_ecs_task_definition" "main" {
  family                   = "main-task-definition"
  container_definitions    = jsonencode([
    {
      name         = "rds"
      image        = var.rds_image
      essential    = true
      portMappings = [
        {
          containerPort = local.containerPort
          hostPort      = local.hostPort
        }
      ],
            environment   = [
                {
                   name   = "DB_HOST",
                    value = var.rds_endpoint

                },
                  {
                   name   = "DB_NAME",
                    value = var.db_name

                },
                  {
                   name   = "DB_USER",
                    value = var.db_username

                },
                  {
                   name   = "DB_PASSWORD",
                    value = var.db_password

                },

                  {
                    name  = "CORS_ALLOWED_ORIGINS"
                    value = var.main_domain

                  }
            ]
      logConfiguration = {
        logDriver      = "awslogs"
        options        = {
          "awslogs-group"         = aws_cloudwatch_log_group.rds.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"   #  Если используете FARGATE
  cpu                      = local.cpu       #  CPU в единицах (256 = 0.25 vCPU)
  memory                   = local.memory        #  Память в мегабайтах
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}
data     "aws_region" "current" {}
resource "aws_cloudwatch_log_group" "rds" {
  name              = "/ecs/my-service-rds"
  retention_in_days = local.retention_in_days
}
resource "aws_ecs_service" "rds" {
  name            = "rds"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = local.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_a_id, var.private_subnet_b_id] #  публичные подсети
    security_groups  = [var.rds_security_group_id] #  Security Group для задач
    assign_public_ip = false #  Для доступа из интернета
  }

  load_balancer {
    target_group_arn = var.aws_lb_target_group_rds_tg_arn #  Подключил к Target Group ALB
    container_name   = local.container_name
    container_port   = local.container_port
  }
   depends_on = [aws_cloudwatch_log_group.rds]
}
