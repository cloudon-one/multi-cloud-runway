resource "google_compute_router" "this" {
  count   = var.cr_enabled ? 1 : 0
  name    = var.router_name
  region  = var.region
  network = var.network
  project = var.project_id

  bgp {
    asn = var.asn

    advertise_mode    = var.cr_bgp_advertise_mode
    advertised_groups = var.cr_bgp_advertised_groups

    dynamic "advertised_ip_ranges" {
      for_each = var.cr_bgp_advertised_ip_ranges

      content {
        range = advertised_ip_ranges.value
      }
    }
  }

}

module "vpn" {
  source  = "terraform-google-modules/vpn/google"
  version = "4.0.0"

  project_id         = var.project_id
  network            = var.network
  region             = var.region
  gateway_name       = var.gateway_name
  tunnel_name_prefix = var.tunnel_name_prefix
  shared_secret      = var.shared_secret
  tunnel_count       = var.tunnel_count
  peer_ips           = var.peer_ips
  peer_asn           = var.peer_asn

  route_priority           = var.route_priority
  remote_subnet            = var.remote_subnet
  cr_name                  = var.cr_enabled ? google_compute_router.this[0].name : null
  cr_enabled               = var.cr_enabled
  bgp_cr_session_range     = var.bgp_cr_session_range
  bgp_remote_session_range = var.bgp_remote_session_range
  vpn_gw_ip                = var.vpn_gw_ip

}
