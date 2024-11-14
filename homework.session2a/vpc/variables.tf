variable "team"{
    default = "devops"
}

variable "env"{
    default = "dev"
}

variable "project"{
    default = "superapp"
}

variable "application_tier"{
    default = "frontend"
}

variable "ManagedBy"{
    default = "terraform"
}

variable "owner"{
    default = "Aisana"
}

variable "vpc_cidr"{
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr"{
    default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr"{
    default = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "azs"{
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "instance_type"{
    type = string
    description = "This is ec2 instance type"
    default = "t2.medium"
}

variable "jenkins-sg"{
    default = "sg-0fb33d189d50abd6e"
}

variable "subnet_id" {
    
}

variable "vpc_id" {
    
}

variable "ubuntu-ami" {
    default = "ami-0866a3c8686eaeeba"
}

variable "domain" {
  default = "aisanaproperties.com"
}