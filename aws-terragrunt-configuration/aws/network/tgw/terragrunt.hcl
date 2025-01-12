include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "dummy_vpc_id"
    private_subnets = ["dummy_subnet_0", "dummy_subnet_1"]
  }
}
dependency "us_dev_vpc" {
  config_path = "../../vpc/us/dev"
  mock_outputs = {
    vpc_id = "dummy_vpc_id"
    private_subnets = ["dummy_subnet_0", "dummy_subnet_1"]
  }
}
dependency "us_prod_vpc" {
  config_path = "../../vpc/us/prod"
  mock_outputs = {
    vpc_id = "dummy_vpc_id"
    private_subnets = ["dummy_subnet_0", "dummy_subnet_1"]
  }
}
dependency "us_stg_vpc" {
  config_path = "../../vpc/us/dev"
  mock_outputs = {
    vpc_id = "dummy_vpc_id"
    private_subnets = ["dummy_subnet_0", "dummy_subnet_1"]
  }
}
dependency "eu_stg_vpc" {
  config_path = "../../vpc/eu/stg"
  mock_outputs = {
    vpc_id = "dummy_vpc_id"
    private_subnets = ["dummy_subnet_0", "dummy_subnet_1"]
  }
}
dependency "eu_prod_vpc" {
  config_path = "../../vpc/eu/prod"
  mock_outputs = {
    vpc_id = "dummy_vpc_id"
    private_subnets = ["dummy_subnet_0", "dummy_subnet_1"]
  }
}


terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-tgw?ref=dev"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  resource      = basename(get_terragrunt_dir())
  account       = basename(dirname(get_terragrunt_dir()))
  resource_vars = local.common_vars["Environments"]["${local.account}"]["Resources"]["${local.resource}"]
}

inputs = merge(
  local.resource_vars["inputs"],
  {
    vpc_attachments = {
      us_dev_vpc  = dependency.us_dev_vpc.outputs.vpc_id,
      us_prod_vpc = dependency.us_prod_vpc.outputs.vpc_id,
      us_stg_vpc  = dependency.us_stg_vpc.outputs.vpc_id,
      eu_stg_vpc  = dependency.eu_stg_vpc.outputs.vpc_id,
      eu_prod_vpc = dependency.eu_prod_vpc.outputs.vpc_id,
    }
  }
)