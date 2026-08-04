# G4-6: VPC Service Controls — stg perimeter, DRY-RUN ONLY.
# Restricted services are DERIVED here from the union of APIs declared across
# stg resources in vars.yaml (never hand-maintained); the module intersects
# them with its VPC-SC-supported list. Scorecard check G4-8 cross-verifies.
# Promotion to enforcement: docs/RUNBOOKS/vpcsc-dryrun-to-enforce.md (out of
# scope for this plan).
# Controls: PCI-DSS 1.3, SOC2 CC6.6, HIPAA 164.312(e)(1).

terraform {
  source = "../../../../tf-modules//terraform-google-vpcsc"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.environment}"]["resources"]["${local.resource}"]

  stg_resources = local.common_vars["envs"]["stg"]["eu"]["resources"]
  candidate_services = distinct(concat(
    try(local.stg_resources["net-vpc"]["inputs"]["active_apis"], []),
    try(local.stg_resources["svc-projects"]["inputs"]["service_projects"]["service"]["active_apis"], []),
  ))
}

inputs = merge(local.resource_vars["inputs"], {
  org_id             = "organizations/${local.common_vars.common.org_id}"
  candidate_services = local.candidate_services
})
