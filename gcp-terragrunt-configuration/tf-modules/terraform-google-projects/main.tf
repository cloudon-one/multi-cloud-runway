data "google_organization" "org" {
  domain = var.domain
}

locals {
  service_accounts = flatten([
    for project, project_config in var.service_projects : [
      for sa in project_config.service_accounts : "${sa}--${project}"
  ]])
  project_outputs = var.service_projects != {} ? { for project, _ in var.service_projects : project => module.service_project[project] } : {}
  vpc_outputs     = var.vpcs != {} ? { for project, _ in var.vpcs : project => module.vpc[project] } : {}
  api_outputs     = var.service_projects != {} ? { for project, _ in var.service_projects : project => module.active_apis[project] } : {}
  sa_outputs = { for project, _ in var.service_projects :
    project => { for sa in google_service_account.service_accounts :
      sa.account_id => sa.email if sa.project == module.service_project[project].project_id
  } }
  key_outputs = var.kms_rings != {} ? { for project, _ in var.kms_rings : project => module.kms_rings[project] } : {}
}

module "service_project" {
  for_each                    = var.service_projects
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "15.0.1"
  name                        = var.service_project_name
  random_project_id           = true
  org_id                      = data.google_organization.org.org_id
  folder_id                   = var.service_projects[each.key].folder_id
  billing_account             = var.billing_account
  default_service_account     = var.service_projects[each.key].default_service_account
  lien                        = var.service_projects[each.key].lien
  disable_dependent_services  = var.service_projects[each.key].disable_dependent_services
  disable_services_on_destroy = var.service_projects[each.key].disable_services_on_destroy
  svpc_host_project_id        = var.service_projects[each.key].shared_vpc_host_name
  shared_vpc_subnets          = var.service_projects[each.key].shared_vpc_subnets
}

module "active_apis" {
  for_each      = var.service_projects
  source        = "terraform-google-modules/project-factory/google//modules/project_services"
  version       = "15.0.1"
  activate_apis = var.service_projects[each.key].active_apis
  project_id    = module.service_project[each.key].project_id
  depends_on    = [module.service_project]
}

module "vpc" {
  for_each                               = var.vpcs
  source                                 = "terraform-google-modules/network/google"
  version                                = "9.1.0"
  project_id                             = module.service_project[each.key].project_id
  network_name                           = var.vpcs[each.key].network_name
  delete_default_internet_gateway_routes = false
  subnets                                = var.vpcs[each.key].subnets
  secondary_ranges                       = var.vpcs[each.key].secondary_ranges
  depends_on = [
    module.service_project,
    module.active_apis,
  ]
}

resource "google_service_account" "service_accounts" {
  for_each   = toset(distinct(local.service_accounts))
  project    = module.service_project[split("--", each.key).1].project_id
  account_id = split("--", each.key)[0]
}

# Cloudkms vault key ring

module "kms_rings" {
  for_each = var.kms_rings
  source   = "terraform-google-modules/kms/google"
  version  = "2.3.0"

  project_id     = module.service_project[each.key].project_id
  location       = var.kms_rings[each.key].location
  keyring        = var.kms_rings[each.key].keyring
  keys           = var.kms_rings[each.key].keys
  set_owners_for = var.kms_rings[each.key].set_owners_for
  owners         = var.kms_rings[each.key].owners
}
