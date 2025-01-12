output "vpc_ids" {
  description = "IDs of the created VPCs"
  value       = { for k, v in module.vpc : k => v.vpc_id }
}

output "private_subnet_ids" {
  description = "IDs of the created private subnets"
  value       = { for k, v in module.vpc : k => v.private_subnets }
}

output "public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = { for k, v in module.vpc : k => v.public_subnets }
}