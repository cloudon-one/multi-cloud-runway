terraform {
  source = "../../../../../tf-modules//terraform-google-vpn"
}

inputs = merge(local.resource_vars["inputs"], {
  project_id = dependency.net-vpc.outputs.project_id
  region     = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["Region"]
})

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  folder        = basename(dirname(dirname(get_terragrunt_dir())))
  folder_id     = "${local.folder}/${local.environment}"
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["Resources"]["${local.resource}"]
}

dependency "net-vpc" {
  config_path = "../net-vpc"
}

include {
  path = find_in_parent_folders()
}
