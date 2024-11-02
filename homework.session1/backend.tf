terraform {
  backend "s3" {
    bucket  = "my-terraform-state-bucket-aisana"
    key     = "jenkins-may24/homework.session1/terraform.tfstate" #this is path for S3 bucket
    region  = "us-east-1"
    encrypt = true
  }
}