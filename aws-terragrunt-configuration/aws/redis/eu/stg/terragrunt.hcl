include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "env" {
  path   = find_in_parent_folders("_env.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../../../vpc/eu/stg"
  mock_outputs = {
    vpc_id                        = "vpc-mock"
    private_subnets               = ["subnet-mock-0", "subnet-mock-1"]
    elasticache_subnets           = ["subnet-mock-0", "subnet-mock-1"]
    redis_sg_id                   = ["sg-mock"]
    elasticache_subnet_group_name = "mock-subnet-group"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-redis?ref=${include.env.locals.module_ref}"
}

inputs = merge(
  include.env.locals.resource_vars["inputs"],
  {
    cluster_id         = "${include.env.locals.location}-${include.env.locals.environment}-${include.env.locals.resource}"
    subnet_ids         = dependency.vpc.outputs.elasticache_subnets
    security_group_ids = dependency.vpc.outputs.redis_sg_id
    subnet_group_name  = dependency.vpc.outputs.elasticache_subnet_group_name
  }
)
