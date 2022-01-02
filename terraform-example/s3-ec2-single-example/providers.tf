# Terraform configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  ## v Everything between the comments is localstack specific v
  access_key                  = var.aws_access_key
  secret_key                  = var.aws_secret_key
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
    s3 = "http://localhost:4566"
  }
  ## ^ Everything between the comments is localstack specific ^
}
