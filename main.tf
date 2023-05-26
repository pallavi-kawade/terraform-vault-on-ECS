resource "aws_ecr_repository" "repo" {
  name = "vault-repo"
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version   = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "myEcsTaskExecutionRole1"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}
# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#################### sevice
resource "aws_ecs_service" "ecs_service" {
  name             = "my-ecs-fargate-service"
  cluster          = aws_ecs_cluster.cluster.id
  task_definition  = aws_ecs_task_definition.app-keycloak.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  network_configuration {
  security_groups  = [aws_security_group.ecs_tasks.id]
  assign_public_ip = true
  subnets          = ["${aws_subnet.subnet_a.id}", "${aws_subnet.subnet_b.id}", "${aws_subnet.subnet_c.id}"]

  }
  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "vault"
    container_port   = 8080
  }
  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

##############################################
resource "aws_alb" "main" {
  name            = "vault"
  subnets         = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id,
  ]

  security_groups = [aws_security_group.lb.id]
}
resource "aws_alb_target_group" "app" {
  name        = "vault"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}
# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn   = aws_alb.main.id
  port                = 443
  protocol            = "HTTPS"
  ssl_policy          = "ELBSecurityPolicy-2016-08"
  certificate_arn     = aws_acm_certificate.ssl_certificate.arn
  default_action {
    target_group_arn  = aws_alb_target_group.app.id
    type              = "forward"
  }
}

###########################################
resource "aws_vpc" "vpc_id" {
}

# Providing a reference to subnets
resource "aws_subnet" "subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet_b" {
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "subnet_c" {
  availability_zone = "us-east-1c"
}