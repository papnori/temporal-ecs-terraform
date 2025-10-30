####################################################################
# Environment Configuration
####################################################################
env = "dev"

####################################################################
# VPC Configuration
####################################################################
vpc_cidr               = "10.0.0.0/16"
vpc_availability_zones = ["us-east-1a", "us-east-1b"]
vpc_public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]


####################################################################
# ECS Cluster Configuration
####################################################################
ecs_cluster_cloudwatch_log_group_retention_in_days = 7


######################################################################
# Worker Container Configuration
######################################################################
worker_cpu            = 1024
worker_memory         = 2048
worker_container_name = "sample-temporal-worker"

# Uncomment and match to your ECR repository and tag
# worker_container_image = <REPLACE_WITH_YOUR_ECR_REPOSITORY_AND_TAG>


######################################################################
# S3 Application Data Bucket Configuration
######################################################################

# Uncomment and set to your desired S3 bucket name
# Note: The bucket name must be globally unique!
# s3_data_bucket_name = "sample-temporal-data-dev"