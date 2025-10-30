variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

#############################################################################
# VPC and Networking Variables
# ###########################################################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_availability_zones" {
  description = "Availability Zones for the VPC"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}


##############################################################################
# ECS Cluster Configuration Variables
##############################################################################

variable "ecs_cluster_cloudwatch_log_group_retention_in_days" {
  description = "The number of days to retain log events in the ECS cluster's CloudWatch log group"
  type        = number
  default     = 7
}

##############################################################################
# Worker Container Configuration Variables
##############################################################################

variable "worker_cpu" {
  description = "CPU units for the worker container"
  type        = number
  default     = 256
}

variable "worker_memory" {
  description = "Memory in MiB for the worker container"
  type        = number
  default     = 512
}

variable "worker_container_name" {
  description = "Name of the temporal worker container"
  type        = string
  default     = "sample-temporal-worker"
}

variable "worker_container_image" {
  description = "Docker image for the temporal worker"
  type        = string
}

##############################################################################
# S3 Application Data Bucket Configuration Variables
##############################################################################

variable "s3_data_bucket_name" {
  description = "Name of the S3 data bucket"
  type        = string
}