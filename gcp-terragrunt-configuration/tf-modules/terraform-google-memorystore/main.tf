resource "google_compute_global_address" "google-managed-svc" {
  provider      = google-beta
  project       = var.host_project
  name          = "redis-${var.vpc_network}"
  purpose       = "VPC_PEERING"
  address       = var.address
  prefix_length = var.prefix_length
  ip_version    = var.ip_version
  address_type  = "INTERNAL"
  network       = var.vpc_network
}

# Creates the peering with the producer network.
resource "google_service_networking_connection" "private_service_access" {
  provider                = google-beta
  network                 = var.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.google-managed-svc.name]
}

resource "null_resource" "dependency_setter" {
  depends_on = [google_service_networking_connection.private_service_access]
}
module "memorystore" {
  source  = "terraform-google-modules/memorystore/google"
  version = "10.0.0"

  name                    = var.name
  project                 = var.project_id
  alternative_location_id = var.alternative_location_id
  auth_enabled            = var.auth_enabled
  authorized_network      = var.authorized_network
  connect_mode            = var.connect_mode
  display_name            = var.display_name
  enable_apis             = var.enable_apis
  labels                  = var.labels
  location_id             = var.location_id
  memory_size_gb          = var.memory_size_gb
  redis_configs           = var.redis_configs
  redis_version           = var.redis_version
  region                  = var.region
  reserved_ip_range       = "redis-${var.vpc_network}"
  tier                    = var.tier
}
