include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "env" {
  path   = find_in_parent_folders("_env.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../../../vpc/us/dev"
  mock_outputs = {
    vpc_id          = "vpc-mock"
    private_subnets = ["subnet-mock-0", "subnet-mock-1"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-eks?ref=${include.env.locals.module_ref}"
}

inputs = merge(
  include.env.locals.resource_vars["inputs"],
  {
    cluster_name = "${include.env.locals.location}-${include.env.locals.environment}-${include.env.locals.resource}"
    vpc_id       = dependency.vpc.outputs.vpc_id
    subnet_ids   = dependency.vpc.outputs.private_subnets
  }
)
