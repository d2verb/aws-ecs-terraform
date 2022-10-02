resource "aws_security_group" "alb" {
  name = "learn-ecs-alb-sg"

  vpc_id = aws_vpc.learn_ecs.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "learn-ecs-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  type = "ingress"

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "learn_ecs" {
  name                       = "learn-ecs-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]
  enable_deletion_protection = false
}

resource "aws_lb_listener" "learn_ecs" {
  port     = "80"
  protocol = "HTTP"

  load_balancer_arn = aws_lb.learn_ecs.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.learn_ecs.arn
  }
}

resource "aws_lb_target_group" "learn_ecs" {
  name        = "learn-ecs-tg"
  vpc_id      = aws_vpc.learn_ecs.id
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_listener_rule" "learn_ecs" {
  listener_arn = aws_lb_listener.learn_ecs.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.learn_ecs.id
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}