terraform {
  source = "../../../../../tf-modules//terraform-google-peering"
}

inputs = merge(local.resource_vars["inputs"], {

  environment       = local.environment
  host_project_name = dependency.net-vpc.outputs.project_id
  subnets           = dependency.net-vpc.outputs.subnets
  local_network     = dependency.net-vpc.outputs.network_self_link
  peer_network      = dependency.eu_dev.outputs.network_self_link
  peer_network      = dependency.eu_stg.outputs.network_self_link
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

dependency "eu_dev" {
  config_path = "../../../dev/eu/net-vpc"
}

dependency "eu_stg" {
  config_path = "../../../stg/eu/net-vpc"
}

dependency "net-vpc" {
  config_path = "../net-vpc"
}

include {
  path = find_in_parent_folders()
}
