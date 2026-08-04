# G4-2: organization policy library.
# Enforcing at the stg folder, dry-run at org scope (G4-3) — scope table in
# docs/preprod/ORG_POLICY_SCOPE.md.
# Controls: CIS GCP 1.4/1.x, PCI-DSS 7.x, SOC2 CC6.1.

terraform {
  source = "../../../../tf-modules//terraform-google-org-policies"
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
  org_id              = "organizations/${local.common_vars.common.org_id}"
  enforcement_folders = [dependency.admin.outputs.folders["stg/eu"].name]
})
