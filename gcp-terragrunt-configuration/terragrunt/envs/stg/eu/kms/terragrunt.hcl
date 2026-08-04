# G4-10: stg CMEK keyrings/keys. Keys per data service, rotation from vars.
# Service-agent IAM bindings need project numbers that exist only post-apply:
# generate them with `make cmek-wiring` (CMEK_WIRING.md, G4-11).
# Controls: PCI-DSS 3.4/3.6.4, CIS GCP 1.10, HIPAA 164.312(a)(2)(iv).

terraform {
  source = "../../../../../tf-modules//terraform-google-kms"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "host_project" {
  config_path = "../net-vpc"
  mock_outputs = {
    project_id = "mock-project"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  folder        = basename(dirname(dirname(get_terragrunt_dir())))
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["resources"]["${local.resource}"]
}

inputs = merge(local.resource_vars["inputs"], {
  project_id = dependency.host_project.outputs.project_id
})
