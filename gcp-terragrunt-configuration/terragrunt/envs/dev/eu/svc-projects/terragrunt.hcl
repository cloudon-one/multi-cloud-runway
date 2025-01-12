terraform {
  source = "../../../../../tf-modules//terraform-google-projects"
}

inputs = merge(local.resource_vars["inputs"], {

  service_projects = {
    service = merge(local.resource_vars["inputs"]["service_projects"]["service"], {
      folder_id            = dependency.admin.outputs.folders["${local.folder_id}"].name
      shared_vpc_host_name = dependency.net-vpc.outputs.project_id
      shared_vpc_subnets   = dependency.net-vpc.outputs.subnets_self_links
    })
  }
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
  "../net-vpc"
] }

dependency "admin" {
  config_path = "../../../global/admin"
}

dependency "net-vpc" {
  config_path = "../net-vpc"
}

include {
  path = find_in_parent_folders()
}
