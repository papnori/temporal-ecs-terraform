terraform {

  #============================ CREATE THE REMOTE BACKEND STATE FILE STORAGE ============================
  # UNCOMMENT THE FOLLOWING BLOCK TO CREATE THE REMOTE BACKEND STATE FILE STORAGE
  # THIS BLOCK SHOULD BE UNCOMMENTED ONLY ONCE TO CREATE THE REMOTE BACKEND STATE FILE STORAGE
  # AFTER UNCOMMENTING THIS BLOCK, RUN "terraform init" AGAIN TO CREATE THE REMOTE BACKEND STATE FILE STORAGE

  backend "s3" {
    bucket       = "my-little-sample-terraform-state" # name of the bucket globally unique
    key          = "bootstrap/terraform.tfstate"         # path to the state file in the bucket
    region       = "us-east-1"                           # region of the bucket
    use_lockfile = true                                  # instead of dynamodb

    encrypt = true # encrypt the state file

  }
  # ============================ END OF REMOTE BACKEND STATE FILE STORAGE ============================
  # RUN EVERYTHING BELOW THIS LINE, FIRST!


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      "CreatedBy"   = "Skinsight DevOps Team"
      "Environment" = "bootstrap"
      "Project"     = "temporal-ecs-terraform"
      "ManagedBy"   = "Terraform"
    }
  }
}