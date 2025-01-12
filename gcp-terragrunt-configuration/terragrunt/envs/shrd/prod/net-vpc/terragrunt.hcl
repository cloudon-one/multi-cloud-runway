terraform {
  source = "../../../../../tf-modules//terraform-google-shared-vpc"
}

inputs = merge(local.resource_vars["inputs"], {

  folder_id   = dependency.admin.outputs.folders["${local.folder_id}"].name
  environment = local.environment
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

include {
  path = find_in_parent_folders()
}
