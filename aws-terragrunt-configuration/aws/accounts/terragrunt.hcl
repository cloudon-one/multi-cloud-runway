include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-accounts?ref=dev"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["Environments"]["master"]["Resources"]["${local.resource}"]
  }

inputs = merge(
  local.resource_vars,{
    org_id    = local.common_vars.common.org_id,
    org_units = local.common_vars.Environments.master.Resources.org_units.inputs,
    accounts  = local.common_vars.Environments.master.Resources.accounts.inputs
  })

