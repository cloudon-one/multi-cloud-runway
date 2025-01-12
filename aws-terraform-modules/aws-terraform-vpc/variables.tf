variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones for the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets for the VPC"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets for the VPC" 
  type        = list(string)
}

variable "intra_subnets" {
  description = "Intra subnets for the VPC"
  type        = list(string)
}

variable "database_subnets" {
  description = "Database subnets for the VPC"
  type        = list(string)
}

variable "elasticache_subnets" {
  description = "Elasticache subnets for the VPC"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateway for the VPC"
  type        = bool
}

variable "private_subnet_names" {
  description = "Names of the private subnets"
  type        = list(string)
}

variable "public_subnet_names" {
  description = "Names of the public subnets"
  type        = list(string)
}

variable "intra_subnet_names" {
  description = "Names of the intra subnets"
  type        = list(string)
}

variable "database_subnet_names" {
  description = "Names of the database subnets"
  type        = list(string)
}

variable "elasticache_subnet_names" {
  description = "Names of the elasticache subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the VPC"
  type        = map(string)
}

