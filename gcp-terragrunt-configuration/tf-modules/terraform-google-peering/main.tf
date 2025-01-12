module "peering-a-b" {
  source                                    = "terraform-google-modules/network/google//modules/network-peering"
  version                                   = "9.1.0"
  prefix                                    = var.prefix
  local_network                             = var.local_network
  peer_network                              = var.peer_network
  export_local_custom_routes                = var.export_local_custom_routes
  export_local_subnet_routes_with_public_ip = var.export_local_subnet_routes_with_public_ip
  export_peer_custom_routes                 = var.export_peer_custom_routes
  export_peer_subnet_routes_with_public_ip  = var.export_peer_subnet_routes_with_public_ip
}

module "peering-a-c" {
  source                                    = "terraform-google-modules/network/google//modules/network-peering"
  prefix                                    = var.prefix
  local_network                             = var.local_network
  peer_network                              = var.peer_network
  export_local_custom_routes                = var.export_local_custom_routes
  export_local_subnet_routes_with_public_ip = var.export_local_subnet_routes_with_public_ip
  export_peer_custom_routes                 = var.export_peer_custom_routes
  export_peer_subnet_routes_with_public_ip  = var.export_peer_subnet_routes_with_public_ip
  module_depends_on                         = [module.peering-a-b.complete]
}

