include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-scp?ref=dev"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  resource      = basename(get_terragrunt_dir())
  account       = basename(dirname(get_terragrunt_dir()))
  resource_vars = local.common_vars["Environments"]["${local.account}"]["Resources"]["${local.resource}"]
}

inputs = merge(
  local.resource_vars["inputs"],{})