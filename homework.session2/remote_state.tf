data "terraform_remote_state" "remote" {
  backend = "s3"

  config = {
    bucket = "my-terraform-state-bucket-aisana"
    key    = "homeworks/session-4/terraform.tfstate"
    region = "us-east-1"

  }
}