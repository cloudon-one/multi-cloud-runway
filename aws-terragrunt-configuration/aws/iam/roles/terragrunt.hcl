include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "version" {
  path   = find_in_parent_folders("_module_version.hcl")
  expose = true
}

terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-iam/roles?ref=${include.version.locals.module_ref}"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("vars.yaml")))
}

# NOTE: Remote module (aws-terraform-iam/roles) is a placeholder with no variables defined yet.
# Inputs will be added once the module is implemented.