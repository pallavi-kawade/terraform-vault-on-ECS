##############cluster###############
resource "aws_ecs_cluster" "cluster" {
  name = "ecs-cluster" # Name your cluster here
}

############task##################
resource "aws_ecs_task_definition" "app-vault" {
  family                   = "vault-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = jsonencode([
    {
      name            = "repo"
      image           = "${aws_ecr_repository.repo.repository_url}"
      portMappings    = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}