terraform {
  source = "../../../../tf-modules//terraform-google-audit"
}

inputs = merge(local.resource_vars["inputs"], {
  audit_folder            = true
  audit_folder_name       = "${local.resource}"
  log_sink_name           = "${local.common_vars.common.labels.owner}-${local.resource}-logsink"
  topic_name              = "${local.common_vars.common.labels.owner}-${local.resource}"
  audit_project_name      = "${local.common_vars.common.labels.owner}-${local.resource}"
  audit_project_id        = "${local.common_vars.common.labels.owner}-${local.resource}-${local.common_vars.common.suffix}"
  audit_random_project_id = false
  org_parent_folder       = local.common_vars.common.root_folder
})
locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.environment}"]["resources"]["${local.resource}"]
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
