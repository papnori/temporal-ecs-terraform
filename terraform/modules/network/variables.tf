####################################################################
# REQUIRED VARIABLES
####################################################################

variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones for the VPC"
  type        = list(string)
}


variable "private_subnets" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}


variable "vpc_endpoints" {
  description = "Map of VPC endpoints to create"
  type        = map(any)
  default     = {}
}

################################################################
# OPTIONAL VARIABLES
################################################################

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway. If set to true, a NAT Gateway will be created in each private subnet."
  type        = bool
  default     = false
}

variable "enable_single_nat_gateway" {
  description = "Enable single NAT Gateway. If set to true, a single NAT Gateway will be shared across all private subnets."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all VPC resources"
  type        = map(string)
  default     = {}
}
