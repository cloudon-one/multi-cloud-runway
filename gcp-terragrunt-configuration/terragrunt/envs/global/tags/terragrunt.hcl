# G4-4: org tags + inheritance (environment / data-classification /
# compliance-scope), stg folder tagged via inheritance.
# Controls: PCI-DSS 1.1, SOC2 CC6.1.

terraform {
  source = "../../../../tf-modules//terraform-google-org-tags"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.environment}"]["resources"]["${local.resource}"]
}

dependency "admin" {
  config_path = "../admin"
  mock_outputs = {
    folders = {
      "stg/eu" = {
        name   = "folders/mock-stg-eu"
        parent = "organizations/mock"
      }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = merge(local.resource_vars["inputs"], {
  org_id = "organizations/${local.common_vars.common.org_id}"
  folder_bindings = {
    (dependency.admin.outputs.folders["stg/eu"].name) = {
      "environment"      = "stg"
      "compliance-scope" = "pci-dss"
    }
  }
})
