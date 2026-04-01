include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "version" {
  path   = find_in_parent_folders("_module_version.hcl")
  expose = true
}

terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-iam/users?ref=${include.version.locals.module_ref}"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  resource_vars = local.common_vars["Environments"]["master"]["Resources"]["iam"]["inputs"]["users"]
}

inputs = local.resource_vars["inputs"][0]