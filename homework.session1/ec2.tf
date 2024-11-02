resource "aws_instance" "web" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.jenkins-sg]
  user_data_replace_on_change = true
  user_data = file("userdata.sh")
  tags = {
    Name = "jenkins-instance"
  }
}

