terraform {
  source = "../../../../../tf-modules//terraform-google-dns"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  folder        = basename(dirname(dirname(get_terragrunt_dir())))
  folder_id     = "${local.folder}/${local.environment}"
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["resources"]["${local.resource}"]
}

include {
  path = find_in_parent_folders()
}

dependency "net-vpc" {
  config_path = "../net-vpc"
}

inputs = merge(local.resource_vars["inputs"], {
  project_id = dependency.net-vpc.outputs.project_id
  private_visibility_config_networks = [
    dependency.net-vpc.outputs.network_self_link
  ]
})
