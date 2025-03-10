
# --- ECR repo --- #
resource "aws_ecr_repository" "tracking" {
  name = "tracking-pixel"
}

##############################
# ECS Cluster
##############################
resource "aws_ecs_cluster" "tracking_cluster" {
  name = "email-tracking-cluster"
}

# --- Get ECR image URI --- #
locals {
  ecr_image_uri = "${aws_ecr_repository.tracking.repository_url}:latest"
}


##############################
# ECS Task Definition
##############################

variable "region" {
  description = "AWS region"
}

resource "aws_iam_role" "ecs_task_execution_role_tracking" {
  name = "ecsTaskExecutionRoleTracking" # Use a unique name to avoid conflict
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "tracking_task" {
  family                   = "tracking-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role_tracking.arn
  container_definitions = jsonencode([
    {
      name  = "tracking-pixel",
      image = local.ecr_image_uri, # e.g. "123456789012.dkr.ecr.eu-west-1.amazonaws.com/tracking-pixel:latest"
      portMappings = [
        {
          containerPort = 5000,
          hostPort      = 5000,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/tracking-app",
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_tracking" {
  role       = aws_iam_role.ecs_task_execution_role_tracking.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##############################
# ECS Service
##############################
resource "aws_ecs_service" "tracking_service" {
  name            = "tracking-service"
  cluster         = aws_ecs_cluster.tracking_cluster.id
  task_definition = aws_ecs_task_definition.tracking_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.email_read_receipts_1.id,
      aws_subnet.email_read_receipts_2.id
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "tracking-pixel"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.http]
}
