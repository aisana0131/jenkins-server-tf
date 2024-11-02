variable "instance_type" {
  type        = string
  description = "This is instance type"
  default     = "t2.medium"

}

variable "env" {
    default = "homework"
  
}

variable "jenkins-sg"{
    default = "sg-0fb33d189d50abd6e"
}