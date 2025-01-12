data "google_organization" "org" {
  domain = var.domain
}

data "google_folder" "org_parent_folder" {
  count               = var.org_parent_folder != "" ? 1 : 0
  folder              = var.org_parent_folder
  lookup_organization = false
}

resource "google_folder" "audit_folder" {
  count        = var.audit_folder ? 1 : 0
  display_name = var.audit_folder_name
  parent       = var.org_parent_folder != "" ? data.google_folder.org_parent_folder.0.id : data.google_organization.org.name
}

module "audit_project" {
  source                     = "terraform-google-modules/project-factory/google"
  version                    = "15.0.1"
  name                       = var.audit_project_name
  project_id                 = var.audit_project_id
  random_project_id          = var.audit_random_project_id
  org_id                     = data.google_organization.org.org_id
  folder_id                  = var.audit_folder ? google_folder.audit_folder.0.name : null
  billing_account            = var.billing_account
  default_service_account    = "deprivilege"
  lien                       = true
  disable_dependent_services = true
  activate_apis = [
    "logging.googleapis.com",
    "compute.googleapis.com",
    "pubsub.googleapis.com",
  ]
}

module "log_export" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "8.1.0"
  destination_uri        = module.destination.destination_uri
  filter                 = "logName:\"logs/cloudaudit.googleapis.com\""
  log_sink_name          = var.log_sink_name
  parent_resource_id     = var.org_parent_folder
  parent_resource_type   = "folder"
  unique_writer_identity = true
  include_children       = true
}

module "destination" {
  source                   = "terraform-google-modules/log-export/google//modules/pubsub"
  project_id               = module.audit_project.project_id
  topic_name               = var.topic_name
  log_sink_writer_identity = module.log_export.writer_identity
  create_subscriber        = true
}
