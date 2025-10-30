#######################################################################
# VPC Module
# This module creates a VPC with public and private subnets, and
# an internet gateway
#######################################################################


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"

  name = var.name
  cidr = var.cidr


  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.enable_single_nat_gateway

  tags = var.tags
}

#######################################################################
# VPC Endpoints Module
# This module creates VPC endpoints for AWS services
#######################################################################

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "6.4.0"

  vpc_id = module.vpc.vpc_id

  endpoints = var.vpc_endpoints

  tags = var.tags
}