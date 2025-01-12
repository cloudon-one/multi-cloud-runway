terraform {
  source = "../../../../../tf-modules//terraform-google-memorystore"
}

include {
  path = find_in_parent_folders()
}

dependency "host_project" {
  config_path = "../net-vpc"
}
dependency "gke_project" {
  config_path = "../svc-projects"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  folder        = basename(dirname(dirname(get_terragrunt_dir())))
  folder_id     = "${local.folder}/${local.environment}"
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["Resources"]["${local.resource}"]

}

inputs = merge(local.resource_vars["inputs"], {
  project_id         = dependency.gke_project.outputs.projects["service"].project_id
  host_project       = dependency.host_project.outputs.project_id
  network            = dependency.host_project.outputs.network_self_link
  vpc_network        = dependency.host_project.outputs.network_name
  authorized_network = dependency.host_project.outputs.network_self_link
})
