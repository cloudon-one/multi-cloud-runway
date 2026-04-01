include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "env" {
  path   = find_in_parent_folders("_env.hcl")
  expose = true
}

terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-apigw?ref=${include.env.locals.module_ref}"
}

inputs = {
  api_gateways = include.env.locals.resource_vars.inputs
}
