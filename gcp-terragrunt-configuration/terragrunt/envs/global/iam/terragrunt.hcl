terraform {
  source = "../../../../tf-modules//terraform-google-iam-permissions"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.environment}"]["resources"]["${local.resource}"]
}

inputs = {
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
