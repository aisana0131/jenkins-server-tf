resource "aws_instance" "web" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type          = "t2.medium"
  key_name               = "aisan@DESKTOP-7AMO459"
  vpc_security_group_ids = [var.jenkins-sg]
  user_data_replace_on_change = true
  user_data = file("userdata.sh")
  tags = {
    Name = "jenkins-instance"
  }
}





