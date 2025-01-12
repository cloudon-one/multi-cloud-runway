resource "google_compute_global_address" "google-managed-services-range" {
  provider      = google-beta
  project       = var.network_project_id
  name          = "sql-${var.vpc_network}"
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
  reserved_peering_ranges = [google_compute_global_address.google-managed-services-range.name]
}

resource "null_resource" "dependency_setter" {
  depends_on = [google_service_networking_connection.private_service_access]
}


module "pg" {
  source                           = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version                          = "21.0.0"
  project_id                       = var.project_id
  name                             = var.name
  random_instance_name             = var.random_instance_name
  database_version                 = var.database_version
  region                           = var.region
  tier                             = var.tier
  zone                             = var.zone
  activation_policy                = var.activation_policy
  availability_type                = var.availability_type
  disk_autoresize                  = var.disk_autoresize
  disk_size                        = var.disk_size
  disk_type                        = var.disk_type
  pricing_plan                     = var.pricing_plan
  maintenance_window_day           = var.maintenance_window_day
  maintenance_window_hour          = var.maintenance_window_hour
  maintenance_window_update_track  = var.maintenance_window_update_track
  database_flags                   = var.database_flags
  user_labels                      = var.user_labels
  backup_configuration             = var.backup_configuration
  ip_configuration                 = var.ip_configuration
  read_replicas                    = var.read_replicas
  read_replica_name_suffix         = var.read_replica_name_suffix
  create_timeout                   = var.create_timeout
  db_name                          = var.db_name
  db_charset                       = var.db_charset
  db_collation                     = var.db_collation
  additional_databases             = var.additional_databases
  user_name                        = var.user_name
  user_password                    = var.user_password
  additional_users                 = var.additional_users
  encryption_key_name              = var.encryption_key_name
  deletion_protection              = var.deletion_protection
  read_replica_deletion_protection = var.read_replica_deletion_protection
  enable_default_db                = var.enable_default_db
  enable_default_user              = var.enable_default_user
  delete_timeout                   = var.delete_timeout
  iam_user_emails                  = var.iam_user_emails
  insights_config                  = var.insights_config
  module_depends_on                = var.module_depends_on
  update_timeout                   = var.update_timeout
}
