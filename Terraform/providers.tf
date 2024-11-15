terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70.0"
    }
  }
  required_version = ">= 1.9.7"
}

provider "aws" {
  access_key = var.aws_access_key # Replace with your AWS access key ID (leave empty if using IAM roles or env vars)
  secret_key = var.aws_secret_key # Replace with your AWS secret access key (leave empty if using IAM roles or env vars)
  region     = var.region         # Specify the AWS region where resources will be created (e.g., us-east-1, us-west-2)
}

