include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "version" {
  path   = find_in_parent_folders("_module_version.hcl")
  expose = true
}

terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-sns?ref=${include.version.locals.module_ref}"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  resource      = basename(get_terragrunt_dir())
  account       = basename(dirname(get_terragrunt_dir()))
  resource_vars = local.common_vars["Environments"]["${local.account}"]["Resources"]["${local.resource}"]
}

inputs = {
  topics        = local.resource_vars["inputs"]["topics"]
  subscriptions = local.resource_vars["inputs"]["subscriptions"]
}