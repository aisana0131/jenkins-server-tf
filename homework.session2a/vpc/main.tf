##### AWS VPC #####
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
    tags = merge (
    {Name = format(local.name, "vpc")},
  local.common_tags
  )
}


###### AWS PUBLIC SUBNETS #####
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  tags = merge (
    {Name = format(local.name, "pub-sub-${count.index+1}")},
  local.common_tags
  )
}

###### AWS PRIVATE SUBNETS #####
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  tags = merge (
    {Name = format(local.name, "priv-sub-${count.index+1}")},
  local.common_tags
  )
}

##### INTERNET GATEWAY ######
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    {Name = format(local.name, "igw")},
  local.common_tags
  )
}

###### PUBLIC ROUTE TABLE ##########
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = merge (
    {Name = format(local.name, "public-rt")},
  local.common_tags
  )
}

###### PUBLIC SUBNETS ASSOCIATION #####
resource "aws_route_table_association" "public_rt_association" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

##### EIP #######
resource "aws_eip" "lb" {
  domain = "vpc"
}

##### NAT GATEWAY #####
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge (
    {Name = format(local.name, "nat-gw")},
  local.common_tags
  )
}

###### PRIVATE ROUTE TABLE ##########
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id =aws_nat_gateway.nat.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = merge (
    {Name = format(local.name, "private-rt")},
  local.common_tags
  )
}

###### PRIVATE SUBNETS ASSOCIATION #####
resource "aws_route_table_association" "private_rt_association" {
  count = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

########## INSTANCE CREATION ######################
resource "aws_instance" "web" {
  ami           = var.ubuntu-ami
  subnet_id = var.subnet_id
  key_name               = "aisan@DESKTOP-7AMO459"
  instance_type = var.instance_type
  vpc_security_group_ids = [var.jenkins-sg]
  iam_instance_profile = aws_iam_instance_profile.s3_full_access_instance_profile.name 
  user_data_replace_on_change = true
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y && sudo apt upgrade -y
              sudo apt install openjdk-21-jdk -y
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt update -y
              sudo apt install jenkins -y
              sudo systemctl start jenkins && sudo systemctl enable jenkins
              sudo systemctl status jenkins
              EOF
  tags = {
    Name = "s3FullAccess-${var.env}"  // string interpolation 
    env = var.env
  }
}

resource "aws_security_group" "main" {
  vpc_id = var.vpc_id
  name        = "my-sg"
  description = "Allow port 80"
  
  tags = {
    Name = "my-sg"
    env = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "httpd" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


############ CREATION OF IAM ROLE FOR EC2 WITH S3 FULL ACCESS ############3
resource "aws_iam_role" "s3_full_access_role" {
  name = "s3_full_access_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Attach the S3 full access policy to the role
resource "aws_iam_role_policy_attachment" "s3_full_access_attachment" {
  role       = aws_iam_role.s3_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create an instance profile for the IAM role
resource "aws_iam_instance_profile" "s3_full_access_instance_profile" {
  name = "s3_full_access_instance_profile"
  role = aws_iam_role.s3_full_access_role.name
}