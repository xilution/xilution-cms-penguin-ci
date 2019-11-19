terraform {
  backend "s3" {
    bucket = "xilution-cms-penguin-infrastructure-terraform-backend-prod"
    dynamodb_table = "xilution-cms-penguin-infrastructure-terraform-backend-lock"
    region = "us-east-1"
    profile = "xilution-prod"
  }
}
