data "google_organization" "org" {
  domain = var.domain
}

data "google_folder" "org_parent_folder" {
  count               = var.org_parent_folder != "" ? 1 : 0
  folder              = var.org_parent_folder
  lookup_organization = false
}

resource "google_folder" "admin_folder" {
  count        = var.admin_folder ? 1 : 0
  display_name = var.admin_folder_name
  parent       = var.org_parent_folder != "" ? data.google_folder.org_parent_folder.0.id : data.google_organization.org.name
}

module "admin_project" {
  source                     = "terraform-google-modules/project-factory/google"
  version                    = "15.0.1"
  name                       = var.admin_project_name
  project_id                 = var.admin_project_id
  random_project_id          = var.admin_random_project_id
  org_id                     = data.google_organization.org.org_id
  folder_id                  = var.admin_folder ? google_folder.admin_folder.0.name : null
  billing_account            = var.billing_account
  default_service_account    = "deprivilege"
  lien                       = true
  disable_dependent_services = true
  activate_apis              = var.active_apis
}

resource "google_storage_bucket" "terraform_state_buckets" {
  for_each                    = var.environment_state_buckets
  name                        = "${module.admin_project.project_id}-${each.key}"
  project                     = module.admin_project.project_id
  location                    = each.value
  uniform_bucket_level_access = true
  force_destroy               = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "this_admin_state_file" {
  name                        = var.admin_state_bucket
  project                     = module.admin_project.project_id
  location                    = var.admin_state_bucket_location
  uniform_bucket_level_access = true
  force_destroy               = true
  versioning {
    enabled = true
  }
}

resource "google_service_account" "terraform_sa_accounts" {
  for_each   = toset(var.terraform_service_accounts)
  project    = module.admin_project.project_id
  account_id = "terraform-${each.key}"
}
