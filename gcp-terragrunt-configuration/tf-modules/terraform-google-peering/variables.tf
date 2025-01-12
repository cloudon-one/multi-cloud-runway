variable "prefix" {
  description = "Name prefix for the network peerings"
  type        = string
  default     = ""
}

variable "local_network" {
  description = "Resource link of the network to add a peering to"
  type        = string
  default     = ""
}

variable "peer_network" {
  description = "Resource link of the peer network"
  type        = string
  default     = ""
}

variable "export_local_custom_routes" {
  description = "Export custom routes to peer network from local network"
  type        = bool
  default     = true
}

variable "export_local_subnet_routes_with_public_ip" {
  description = "Export custom routes to peer network from local network"
  type        = bool
  default     = true
}

variable "export_peer_custom_routes" {
  description = "Export custom routes to local network from peer network"
  type        = bool
  default     = true
}

variable "export_peer_subnet_routes_with_public_ip" {
  description = "Export custom routes to local network from peer network"
  type        = bool
  default     = true
}

