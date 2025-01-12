output "tgw_id" {
  description = "EC2 Transit Gateway identifier"
  value       = module.tgw.ec2_transit_gateway_id
}

output "tgw_arn" {
  description = "EC2 Transit Gateway Amazon Resource Name (ARN)"
  value       = module.tgw.ec2_transit_gateway_arn
}

output "tgw_route_table_id" {
  description = "EC2 Transit Gateway Route Table identifier"
  value       = module.tgw.ec2_transit_gateway_route_table_id
}

output "vpc_attachments" {
  description = "Map of VPC attachments"
  value       = module.tgw.vpc_attachments
}

output "ram_resource_share_id" {
  description = "The ID of the resource share of TGW"
  value       = module.tgw.ram_resource_share_id
}