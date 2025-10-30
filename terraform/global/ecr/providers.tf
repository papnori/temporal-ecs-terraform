terraform {

  # The backend configuration for storing Terraform state.
  backend "s3" {
    bucket  = "my-little-sample-terraform-state"
    key     = "global/ecr/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  # Required providers for this Terraform configuration.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.0"
}


provider "aws" {
  region = "us-east-1" # Default AWS region for this configuration

  default_tags {
    tags = {
      CreatedBy   = "Skinsight DevOps Team"
      Environment = "global"
      Project     = "temporal-ecs-terraform"
      ManagedBy   = "Terraform"
    }
  }
}