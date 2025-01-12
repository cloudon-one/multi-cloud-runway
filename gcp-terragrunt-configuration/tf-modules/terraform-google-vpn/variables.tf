variable "project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

variable "network" {
  type        = string
  description = "The name of VPC being created"
}

variable "region" {
  type        = string
  description = "The region in which you want to create the VPN gateway"
}

variable "gateway_name" {
  type        = string
  description = "The name of VPN gateway"
  default     = "test-vpn"
}

variable "tunnel_count" {
  type        = number
  description = "The number of tunnels from each VPN gw (default is 1)"
  default     = 1
}

variable "tunnel_name_prefix" {
  type        = string
  description = "The optional custom name of VPN tunnel being created"
  default     = ""
}

variable "local_traffic_selector" {
  description = <<EOD
Local traffic selector to use when establishing the VPN tunnel with peer VPN gateway.
Value should be list of CIDR formatted strings and ranges should be disjoint.
EOD


  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "remote_traffic_selector" {
  description = <<EOD
Remote traffic selector to use when establishing the VPN tunnel with peer VPN gateway.
Value should be list of CIDR formatted strings and ranges should be disjoint.
EOD


  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "peer_ips" {
  type        = list(string)
  description = "IP address of remote-peer/gateway"
}

variable "remote_subnet" {
  description = "remote subnet ip range in CIDR format - x.x.x.x/x"
  type        = list(string)
  default     = []
}

variable "shared_secret" {
  type        = string
  description = "Please enter the shared secret/pre-shared key"
  default     = ""
}

variable "route_priority" {
  description = "Priority for static route being created"
  default     = 1000
}

variable "cr_name" {
  type        = string
  description = "The name of cloud router for BGP routing"
  default     = ""
}

variable "cr_enabled" {
  type        = bool
  description = "If there is a cloud router for BGP routing"
  default     = false
}

variable "peer_asn" {
  type        = list(string)
  description = "Please enter the ASN of the BGP peer that cloud router will use"
  default     = ["65101"]
}

variable "bgp_cr_session_range" {
  type        = list(string)
  description = "Please enter the cloud-router interface IP/Session IP"
  default     = ["", ""]
}

variable "bgp_remote_session_range" {
  type        = list(string)
  description = "Please enter the remote environments BGP Session IP"
  default     = ["", ""]
}

variable "advertised_route_priority" {
  description = "Please enter the priority for the advertised route to BGP peer(default is 100)"
  default     = 100
}

variable "ike_version" {
  type        = number
  description = "Please enter the IKE version used by this tunnel (default is IKEv2)"
  default     = 2
}

variable "vpn_gw_ip" {
  type        = string
  description = "Please enter the public IP address of the VPN Gateway, if you have already one. Do not set this variable to autocreate one"
  default     = ""
}

variable "asn" {
  type        = number
  description = "Router asn"
  default     = null
}

variable "router_name" {
  type        = string
  description = "Router name"
  default     = null
}

variable "cr_bgp_advertise_mode" {
  type        = string
  description = "User-specified flag to indicate which mode to use for advertisement"
  default     = "DEFAULT"
}

variable "cr_bgp_advertised_ip_ranges" {
  type        = list(string)
  description = "User-specified list of individual IP ranges to advertise in custom mode. This field can only be populated if advertiseMode is CUSTOM and is advertised to all peers of the router. These IP ranges will be advertised in addition to any specified groups"
  default     = []
}

variable "cr_bgp_advertised_groups" {
  type        = list(string)
  description = "User-specified list of prefix groups to advertise in custom mode. This field can only be populated if advertiseMode is CUSTOM and is advertised to all peers of the router. These groups will be advertised in addition to any specified prefixes. Leave this field blank to advertise no custom groups. This enum field has the one valid value: ALL_SUBNETS"
  default     = ["ALL_SUBNETS"]
}
