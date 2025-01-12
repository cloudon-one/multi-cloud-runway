data "google_organization" "org" {
  domain = var.domain
}

module "host_project" {
  source                     = "terraform-google-modules/project-factory/google"
  version                    = "15.0.1"
  name                       = var.host_project_name
  random_project_id          = true
  org_id                     = data.google_organization.org.org_id
  folder_id                  = var.folder_id
  billing_account            = var.billing_account
  default_service_account    = var.default_service_account
  lien                       = var.lien
  disable_dependent_services = true
  activate_apis              = var.active_apis
}

module "vpc" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "9.1.0"
  project_id                             = module.host_project.project_id
  network_name                           = var.network_name
  delete_default_internet_gateway_routes = false
  shared_vpc_host                        = true
  subnets                                = var.subnets
  secondary_ranges                       = var.secondary_ranges
}

module "subnets_beta" {
  source       = "terraform-google-modules/network/google//modules/subnets-beta"
  version      = "9.1.0"
  project_id   = module.host_project.project_id
  network_name = var.network_name
  subnets      = var.subnets_beta
}

module "cloud-nat" {
  for_each                           = toset(keys(var.cloud_nats))
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "5.2.0"
  project_id                         = module.vpc.project_id
  region                             = each.key
  create_router                      = true
  router                             = var.cloud_nats[each.key].router_name
  subnetworks                        = var.cloud_nats[each.key].subnetworks
  source_subnetwork_ip_ranges_to_nat = var.cloud_nats[each.key].source_subnetwork_ip_ranges_to_nat
  router_asn                         = var.cloud_nats[each.key].router_asn
  log_config_enable                  = var.cloud_nats[each.key].log_config_enable
  log_config_filter                  = var.cloud_nats[each.key].log_config_filter
  network                            = module.vpc.network_name
}

resource "google_service_account" "service_accounts" {
  for_each   = toset(distinct(var.service_accounts))
  project    = module.host_project.project_id
  account_id = each.key
}
