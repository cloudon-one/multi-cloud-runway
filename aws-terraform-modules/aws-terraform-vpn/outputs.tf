output "tunnel1_preshared_key" {
  value = module.vpn-gateway.tunnel1_preshared_key
}

output "tunnel2_preshared_key" {
  value = module.vpn-gateway.tunnel2_preshared_key
}

output "vpn_connection_customer_gateway_configuration" {
  value = module.vpn-gateway.vpn_connection_customer_gateway_configuration
}

output "vpn_connection_id" {
  value = module.vpn-gateway.vpn_connection_id
}

output "vpn_connection_transit_gateway_attachment_id" {
  value = module.vpn-gateway.vpn_connection_transit_gateway_attachment_id
}

output "vpn_connection_tunnel1_address" {
  value = module.vpn-gateway.vpn_connection_tunnel1_address
}

output "vpn_connection_tunnel1_cgw_inside_address" {
  value = module.vpn-gateway.vpn_connection_tunnel1_cgw_inside_address
}

output "vpn_connection_tunnel1_vgw_inside_address" {
  value = module.vpn-gateway.vpn_connection_tunnel1_vgw_inside_address
}

output "vpn_connection_tunnel2_address" {
  value = module.vpn-gateway.vpn_connection_tunnel2_address
}

output "vpn_connection_tunnel2_cgw_inside_address" {
  value = module.vpn-gateway.vpn_connection_tunnel2_cgw_inside_address
}

output "vpn_connection_tunnel2_vgw_inside_address" {
  value = module.vpn-gateway.vpn_connection_tunnel2_vgw_inside_address
}