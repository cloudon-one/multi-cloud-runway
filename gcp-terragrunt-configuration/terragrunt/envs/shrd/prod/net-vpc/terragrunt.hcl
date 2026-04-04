terraform {
  source = "../../../../../tf-modules//terraform-google-svpc"
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
  mock_outputs = {
    folders = {
      "dev/eu" = {
        name   = "folders/mock-dev-eu"
        parent = "organizations/mock"
      }
      "prod/eu" = {
        name   = "folders/mock-prod-eu"
        parent = "organizations/mock"
      }
      "prod/us" = {
        name   = "folders/mock-prod-us"
        parent = "organizations/mock"
      }
      "shrd/dev" = {
        name   = "folders/mock-shrd-dev"
        parent = "organizations/mock"
      }
      "shrd/prod" = {
        name   = "folders/mock-shrd-prod"
        parent = "organizations/mock"
      }
      "stg/eu" = {
        name   = "folders/mock-stg-eu"
        parent = "organizations/mock"
      }
      "mgmt" = {
        name   = "folders/mock-mgmt"
        parent = "organizations/mock"
      }
    }
    network_self_link = "projects/mock/global/networks/mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

include "root" {
  path = find_in_parent_folders()
}
