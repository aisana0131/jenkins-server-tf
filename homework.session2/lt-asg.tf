resource "aws_launch_template" "ec2" {
  image_id               = var.amazon_linux_ami
  instance_type          = var.instance_type
  key_name               = "aisan@DESKTOP-7AMO459"

  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = data.terraform_remote_state.remote.outputs.private_subnet_ids[1]
    security_groups             = [aws_security_group.sg_for_ec2.id]
  }
  user_data = filebase64("${path.module}/extra/userdata.sh")
  tags = merge(
    { Name = format(local.name, "ec2-lt") },
    local.common_tags
  )
}

resource "aws_security_group" "sg_for_ec2" {
  name        = format(local.name, "ec2-sg")
  description = "Terraform load balancer security group"
  vpc_id      = data.terraform_remote_state.remote.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = format(local.name, "lt-sg") },
    local.common_tags
  )

}


resource "aws_autoscaling_group" "bar" {
  name = format(local.name, "asg")
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.my_tg.arn]
  vpc_zone_identifier = data.terraform_remote_state.remote.outputs.private_subnet_ids[*]
  launch_template {
    id      = aws_launch_template.ec2.id
    version = "$Latest"
  }

}