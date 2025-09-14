output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = module.vpc.igw_id
}

output "internet_gateway_arn" {
  description = "ARN of the internet gateway"
  value       = module.vpc.igw_arn

}


output "nat_gateway_ids" {
  description = "IDs of the NAT gateways"
  value       = module.vpc.nat_ids
}

output "nat_public_ips" {
  description = "Public IPs of the NAT gateways"
  value       = module.vpc.nat_public_ips

}


output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block

}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = module.vpc.private_route_table_ids
}