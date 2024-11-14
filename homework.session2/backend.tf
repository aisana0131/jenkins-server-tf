terraform {
  backend "s3" {
    bucket  = "my-terraform-state-bucket-aisana"
    key     = "homeworks/session-5/terraform.tfstate" #this is path for S3 bucket
    region  = "us-east-1"
    encrypt = true
  }
}