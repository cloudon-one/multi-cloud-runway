terraform {
  source = "../../../../tf-modules//terraform-google-iam-permissions"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.environment}"]["resources"]["${local.resource}"]
}

inputs =  {
  project = dependency.gke_project.outputs.projects["service"].project_id
  folders_iam = {
    "${dependency.admin.outputs.folders["mgmt"].parent}" = {
      bindings = merge(local.resource_vars["inputs"]["folder"]["bindings"], {})
    }
  }
}

dependencies { paths = [
  "../admin"
] }

dependency "admin" {
  config_path = "../admin"
}

dependency "gke_project" {
  config_path = "../svc-projects"
}

include {
  path = find_in_parent_folders()
}
