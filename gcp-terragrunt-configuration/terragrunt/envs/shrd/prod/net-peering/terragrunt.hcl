terraform {
  source = "../../../../../tf-modules//terraform-google-peering"
}

inputs = merge(local.resource_vars["inputs"], {

  environment       = local.environment
  host_project_name = dependency.net-vpc.outputs.project_id
  local_network     = dependency.net-vpc.outputs.network_self_link
  peer_network      = dependency.prod_us.outputs.network_self_link
  peer_network      = dependency.prod_eu.outputs.network_self_link
})

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  folder        = basename(dirname(dirname(get_terragrunt_dir())))
  folder_id     = "${local.folder}/${local.environment}"
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["resources"]["${local.resource}"]
}

dependencies { paths = [
  "../../../global/admin"
] }

dependency "admin" {
  config_path = "../../../global/admin"
}

dependency "prod_us" {
  config_path = "../../../prod/us/net-vpc"
}

dependency "prod_eu" {
  config_path = "../../../prod/eu/net-vpc"
}

dependency "net-vpc" {
  config_path = "../net-vpc"
}

include {
  path = find_in_parent_folders()
}
