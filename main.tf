provider "aws" {
  region = "ap-south-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-ecs-cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "medusa_sg" {
  name        = "medusa-sg"
  description = "Allow Medusa traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 9000
    to_port     = 9000
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

resource "aws_cloudwatch_log_group" "medusa_log_group" {
  name              = "/ecs/medusa"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "medusa_task" {
  family                   = "medusa-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "medusa"
    image     = "medusajs/medusa-demo:latest" # ✅ Changed line
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [
      {
        containerPort = 9000
        hostPort      = 9000
        protocol      = "tcp"
      }
    ],
    environment = [
      {
        name  = "NODE_ENV"
        value = "production"
      },
      {
        name  = "MEDUSA_ADMIN_CORS"
        value = "*"
      },
      {
        name  = "MEDUSA_STORE_CORS"
        value = "*"
      },
      {
        name  = "DATABASE_URL"
        value = "postgres://<username>:<password>@<hostname>:5432/<dbname>"
      }
    ],
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/medusa"
        awslogs-region        = "ap-south-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "medusa_service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.medusa_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_attach]
}

