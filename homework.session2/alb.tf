######## LOAD BALANCER #########

resource "aws_lb" "test" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.terraform_remote_state.remote.outputs.public_subnet_ids
  tags = merge(
    { Name = format(local.name, "alb") },
    local.common_tags
  )
}

resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = data.terraform_remote_state.remote.outputs.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = format(local.name, "alb-sg") },
    local.common_tags
  )

}

resource "aws_lb_target_group" "my_tg" {
  name = "alb-tg"
  port = 80
  # target_type = "alb"
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.remote.outputs.vpc_id
  tags = merge(
    { Name = format(local.name, "alb-tg") },
    local.common_tags
  )

}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }

  #   default_action {                    ### redirection from http to https
  #   type = "redirect"

  #   redirect {
  #     port        = "443"
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
  # }

  tags = merge(
    { Name = format(local.name, "alb-listener-http") },
    local.common_tags
  )
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.test.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
  tags = merge(
    { Name = format(local.name, "alb-listener-https") },
    local.common_tags
  )
}