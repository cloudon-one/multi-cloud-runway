terraform {
  source = "../../../../../tf-modules//terraform-google-sql"
}

include {
  path = find_in_parent_folders()
}

dependency "host_project" {
  config_path = "../net-vpc"
}
dependency "sql_project" {
  config_path = "../svc-projects"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  folder        = basename(dirname(dirname(get_terragrunt_dir())))
  folder_id     = "${local.folder}/${local.environment}"
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["resources"]["${local.resource}"]

}

inputs = merge(local.resource_vars["inputs"], {
  project_id         = dependency.sql_project.outputs.projects["service"].project_id
  region             = dependency.host_project.outputs.subnets["$REGION/$SUBNET"].region
  vpc_network        = dependency.host_project.outputs.network_name
  network            = dependency.host_project.outputs.network_self_link
  network_project_id = dependency.host_project.outputs.project_id
  ip_configuration = merge(local.resource_vars["inputs"]["ip_configuration"], {
    private_network = dependency.host_project.outputs.network_self_link
  })
})
