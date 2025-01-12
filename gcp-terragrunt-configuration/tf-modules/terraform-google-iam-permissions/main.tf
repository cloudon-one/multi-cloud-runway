data "google_organization" "org" {
  for_each = toset(keys(var.organizations_iam))
  domain   = each.key
}

module "organization_iam" {
  for_each      = toset(keys(var.organizations_iam))
  source        = "terraform-google-modules/iam/google//modules/organizations_iam"
  version       = "7.7.1"
  organizations = [data.google_organization.org[each.key].org_id]
  mode          = "additive"
  bindings      = var.organizations_iam[each.key].bindings
}

module "folder_iam" {
  for_each = toset(keys(var.folders_iam))
  source   = "terraform-google-modules/iam/google//modules/folders_iam"
  version  = "7.7.1"
  folders  = [each.key]
  mode     = "additive"
  bindings = var.folders_iam[each.key].bindings
}

module "project_iam" {
  for_each = toset(keys(var.projects_iam))
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  version  = "7.7.1"
  projects = [each.key]
  mode     = "additive"
  bindings = var.projects_iam[each.key].bindings
}

module "subnet_iam" {
  for_each = toset(keys(var.subnets_iam))
  source   = "terraform-google-modules/iam/google//modules/subnets_iam"
  version  = "7.7.1"
  subnets  = [each.key]
  subnets_region = element(
    split("/", each.key),
    index(split("/", each.key), "regions") + 1,
  )
  project = element(
    split("/", each.key),
    index(split("/", each.key), "projects") + 1,
  )
  mode     = "additive"
  bindings = var.subnets_iam[each.key].bindings
}

module "storage_buckets_iam" {
  for_each        = toset(keys(var.storage_buckets_iam))
  source          = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  version         = "7.7.1"
  storage_buckets = [each.key]
  mode            = "additive"
  bindings        = var.storage_buckets_iam[each.key].bindings
}

module "service_account_iam" {
  for_each         = toset(keys(var.service_accounts_iam))
  source           = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  version          = "7.7.1"
  service_accounts = [each.value]
  project          = var.service_accounts_iam[each.key].project
  mode             = "additive"
  bindings         = var.service_accounts_iam[each.key].bindings
}

module "workload_identity_iam" {
  for_each    = toset(keys(var.workload_identity_iam))
  source      = "./modules/workload_identity_iam"
  name        = each.key
  k8s_sa_name = var.workload_identity_iam[each.key].k8s_sa_name
  namespace   = var.workload_identity_iam[each.key].namespace
  project_id  = var.workload_identity_iam[each.key].project
  roles       = var.workload_identity_iam[each.key].roles
}

locals {
  shared_vpc_attachments = flatten([for host_project, service_projects in var.shared_vpc_attachments : [for sp in service_projects : "${host_project}/${sp}"]])
}
resource "google_compute_shared_vpc_service_project" "shared_vpc_attachments" {
  for_each        = toset(distinct(local.shared_vpc_attachments))
  host_project    = split("/", each.key)[0]
  service_project = split("/", each.key)[1]
}
