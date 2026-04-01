module "peering" {
  for_each                                  = var.peerings
  source                                    = "terraform-google-modules/network/google//modules/network-peering"
  version                                   = "9.1.0"
  prefix                                    = "${var.prefix}-${each.key}"
  local_network                             = each.value.local_network
  peer_network                              = each.value.peer_network
  export_local_custom_routes                = var.export_local_custom_routes
  export_local_subnet_routes_with_public_ip = var.export_local_subnet_routes_with_public_ip
  export_peer_custom_routes                 = var.export_peer_custom_routes
  export_peer_subnet_routes_with_public_ip  = var.export_peer_subnet_routes_with_public_ip
}
