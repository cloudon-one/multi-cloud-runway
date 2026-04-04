terraform {
  source = "../../../../../tf-modules//terraform-google-dd"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "svc_project" {
  config_path = "../svc-projects"
  mock_outputs = {
    projects = {
      "service" = {
        project_id     = "mock-service-project"
        project_number = "000000000000"
      }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
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
  project_id = dependency.svc_project.outputs.projects["service"].project_id
})
