module "dns" {
  source                       = "terraform-google-modules/cloud-dns/google"
  version                      = "5.2.0"
  project_id                   = var.project_id
  type                         = var.type
  name                         = var.name
  domain                       = var.domain
  target_name_server_addresses = var.target_name_server_addresses
  target_network               = var.target_network
  description                  = var.description
  force_destroy                = var.force_destroy

  dnssec_config = var.dnssec_config
  labels        = var.labels

  default_key_specs_key              = var.default_key_specs_key
  default_key_specs_zone             = var.default_key_specs_zone
  private_visibility_config_networks = var.private_visibility_config_networks

  recordsets = var.recordsets
}

locals {
  is_static_zone = var.type == "public" || var.type == "private"
}

