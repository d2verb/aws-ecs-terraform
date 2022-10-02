resource "aws_ecs_cluster" "learn_ecs" {
  name = "learn_ecs"
}

resource "aws_security_group" "learn_ecs_ecs_service" {
  name   = "learn-ecs-ecs-service-sg"
  vpc_id = aws_vpc.learn_ecs.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "learn-ecs-ecs-service-sg"
  }
}

resource "aws_security_group_rule" "allow_from_alb" {
  security_group_id = aws_security_group.learn_ecs_ecs_service.id

  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  source_security_group_id = aws_security_group.alb.id
}

resource "aws_ecs_service" "learn_ecs" {
  name          = "nginx"
  cluster       = aws_ecs_cluster.learn_ecs.id
  desired_count = 1
  depends_on    = [aws_lb_listener_rule.learn_ecs]

  launch_type = "FARGATE"

  task_definition = aws_ecs_task_definition.learn_ecs.arn

  network_configuration {
    subnets         = [aws_subnet.protected_1a.id, aws_subnet.protected_1c.id]
    security_groups = [aws_security_group.learn_ecs_ecs_service.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.learn_ecs.arn
    container_name   = "nginx"
    container_port   = 80
  }
}

resource "aws_ecs_task_definition" "learn_ecs" {
  family                   = "learn-ecs"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "512"
  network_mode             = "awsvpc"
  container_definitions    = <<EOL
[
  {
    "name": "nginx",
    "image": "nginx:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
EOL
}