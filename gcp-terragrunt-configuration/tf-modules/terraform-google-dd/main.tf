locals {
  project_id = var.project_id != "" ? var.project_id : null
  project_roles = [
    "roles/cloudasset.viewer",
    "roles/compute.viewer",
    "roles/monitoring.viewer",
  ]
  project_services = [
    "cloudasset.googleapis.com",
    "cloudbilling.googleapis.com",
    "compute.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

module "service_account" {
  source  = "nephosolutions/iam-service-account/google"
  version = "3.1.1"

  display_name = "Datadog integration"
  project_id   = local.project_id
}

resource "google_project_service" "required" {
  for_each = toset(local.project_services)

  disable_on_destroy = false
  project            = local.project_id
  service            = each.key
}

resource "google_service_account_key" "datadog" {
  service_account_id = module.service_account.email
}

resource "google_project_iam_member" "service_account" {
  for_each = toset(local.project_roles)

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${module.service_account.email}"
}

resource "datadog_integration_gcp" "project" {
  project_id     = jsondecode(base64decode(google_service_account_key.datadog.private_key))["project_id"]
  private_key    = jsondecode(base64decode(google_service_account_key.datadog.private_key))["private_key"]
  private_key_id = jsondecode(base64decode(google_service_account_key.datadog.private_key))["private_key_id"]
  client_email   = jsondecode(base64decode(google_service_account_key.datadog.private_key))["client_email"]
  client_id      = jsondecode(base64decode(google_service_account_key.datadog.private_key))["client_id"]
  host_filters   = join(",", sort(var.host_filters))
}
