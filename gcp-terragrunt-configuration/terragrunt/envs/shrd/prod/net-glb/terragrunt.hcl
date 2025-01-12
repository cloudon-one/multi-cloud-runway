terraform {
  source = "../../../../../tf-modules//terraform-google-glb"
}

inputs = merge(local.resource_vars["inputs"], {
  project_id  = dependency.net-vpc.outputs.project_id
  svc_project = dependency.gke_project.outputs.projects["service"].project_id
  network     = dependency.net-vpc.outputs.network_self_link
  subnetwork  = dependency.net-vpc.outputs.subnets["$REGION/$SUBNET"].self_link
})

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  folder        = basename(dirname(dirname(get_terragrunt_dir())))
  folder_id     = "${local.folder}/${local.environment}"
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["resources"]["${local.resource}"]
}

dependency "net-vpc" {
  config_path = "../net-vpc"
}

dependency "gke_project" {
  config_path = "../svc-projects"
}


include {
  path = find_in_parent_folders()
}
