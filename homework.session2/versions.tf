terraform {

  required_version = "1.9.5" //terraform/ terrafrom binary version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.63.0"
    }
  }
}