resource "aws_vpc" "project2_v2" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.project2_v2.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "public_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.project2_v2.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "public_subnet_b"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.project2_v2.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "ecs_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.project2_v2.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "ecs_subnet_b"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project2_v2.id

  tags = {
    Name = "internet-gateway"
  }
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.project2_v2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}
resource "aws_route_table_association" "public_subnet_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_subnet_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}
# Elastic IP for --> Nat Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}
# Nat Gateway (привязываем обязательно к публичному сабнету для доступа в интернет)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id # Или public_subnet_b.id - выбирайте одну

  tags = {
    Name = "nat-gateway"
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.project2_v2.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}
resource "aws_route_table_association" "private_subnet_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.project2_v2.id
  service_name = "com.amazonaws.${var.region}.s3"
}
resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.project2_v2.id

  ingress {
    description      = "PostgreSQL access from your IP"
    from_port        = 8001
    to_port          = 8001
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "PostgreSQL access from your IP"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "project2-v2-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  tags = {
    Name = "Project2 v2 DB Subnet Group"
  }
}

# ip target group( tg instance --> for ec2)
resource "aws_lb_target_group" "rds_tg" {
  name        = local.rds_name
  port        = local.port_rds #????
  protocol    = "HTTP"
  target_type = "ip" # Целевой тип - IP-адреса (для Fargate)
  vpc_id      = aws_vpc.project2_v2.id
  health_check {
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/test_connection/" # Путь для проверки здоровья RDS
    port                = "8001"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}
resource "aws_lb_target_group" "redis_tg" {
  name        = "redis-tg"
  port        = 8002
  protocol    = "HTTP"
  target_type = "ip" # Целевой тип - IP-адреса (для Fargate)
  vpc_id      = aws_vpc.project2_v2.id
   health_check {
      path                = "/"
      matcher             = "200"
      interval            = 30
      port                = "8002" # Порт, на котором Redis слушает
      protocol            = "HTTP" #  Скорее всего, Redis использует TCP
      timeout             = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
  }
}
resource "aws_alb" "alb-for-ecs" {
  name               = "alb-for-ecs"
  internal           = false # false - внешний ALB, true - внутренний
  load_balancer_type = "application" # application - для HTTP/HTTPS
  security_groups    = [aws_security_group.alb_sg.id] # Security Group для ALB
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id] # публичные подсети
}
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.project2_v2.id

  # Разрешаем HTTP доступ из любого места (для тестирования)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.alb-for-ecs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect" # Редирект на HTTPS
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.alb-for-ecs.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_ssl

  default_action {
    type = "fixed-response" # Дефолтное действие для HTTPS
    fixed_response {
      content_type = "text/plain"
      message_body = "Default HTTPS action"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "rds_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 5
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rds_tg.arn
  }

  condition {
    host_header {
      values = ["api.themafto.com"]
    }
  }

}
resource "aws_lb_listener_rule" "redis_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis_tg.arn
  }

  condition {
    host_header {
      values = ["cache.themafto.com"]
    }
  }
}

