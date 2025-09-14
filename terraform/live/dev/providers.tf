terraform {

  # The backend configuration for storing Terraform state.
  backend "s3" {
    bucket  = "my-little-sample-terraform-state"
    key     = "live/dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Update to at least 5.0 or higher
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"

  default_tags {
    tags = {
      CreatedBy   = "Skinsight DevOps Team"
      Environment = "dev"
      Project     = "Sample"
      ManagedBy   = "Terraform"
    }
  }
}
