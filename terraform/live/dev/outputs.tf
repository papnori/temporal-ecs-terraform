####################################################################
# VPC Outputs
####################################################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = module.vpc.internet_gateway_id
}

output "internet_gateway_arn" {
  description = "ARN of the internet gateway"
  value       = module.vpc.internet_gateway_arn
}
output "nat_gateway_ids" {
  description = "IDs of the NAT gateways"
  value       = module.vpc.nat_gateway_ids
}

output "nat_public_ips" {
  description = "Public IPs of the NAT gateways"
  value       = module.vpc.nat_public_ips
}