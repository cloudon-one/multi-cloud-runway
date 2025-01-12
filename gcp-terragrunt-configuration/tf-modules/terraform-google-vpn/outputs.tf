output "project_id" {
  description = "The Project-ID"
  value       = module.vpn.project_id
}

output "name" {
  description = "The name of the Gateway"
  value       = module.vpn.name
}

output "gateway_self_link" {
  description = "The self-link of the Gateway"
  value       = module.vpn.gateway_self_link
}

output "network" {
  description = "The name of the VPC"
  value       = module.vpn.network
}

output "gateway_ip" {
  description = "The VPN Gateway Public IP"
  value       = module.vpn.gateway_ip
}

output "vpn_tunnels_names-static" {
  description = "The VPN tunnel name is"
  value       = module.vpn.vpn_tunnels_names-static
}

output "vpn_tunnels_self_link-static" {
  description = "The VPN tunnel self-link is"
  value       = module.vpn.vpn_tunnels_self_link-static
}

output "ipsec_secret-static" {
  description = "The secret"
  value       = module.vpn.ipsec_secret-static
}

output "vpn_tunnels_names-dynamic" {
  description = "The VPN tunnel name is"
  value       = module.vpn.vpn_tunnels_names-dynamic
}

output "vpn_tunnels_self_link-dynamic" {
  description = "The VPN tunnel self-link is"
  value       = module.vpn.vpn_tunnels_self_link-dynamic
}

output "ipsec_secret-dynamic" {
  description = "The secret"
  value       = module.vpn.ipsec_secret-dynamic
}