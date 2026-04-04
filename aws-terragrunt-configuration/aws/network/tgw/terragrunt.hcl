include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "version" {
  path   = find_in_parent_folders("_module_version.hcl")
  expose = true
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
  config_path = "../../vpc/us/stg"
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
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-tgw?ref=${include.version.locals.module_ref}"
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
      us_dev_vpc = {
        vpc_id     = dependency.us_dev_vpc.outputs.vpc_id,
        subnet_ids = dependency.us_dev_vpc.outputs.private_subnets,
        tgw_routes = [
          { destination_cidr_block = "10.32.0.0/16" },
          { destination_cidr_block = "0.0.0.0/0", blackhole = true },
        ]
      },
      us_stg_vpc = {
        vpc_id     = dependency.us_stg_vpc.outputs.vpc_id,
        subnet_ids = dependency.us_stg_vpc.outputs.private_subnets,
        tgw_routes = [
          { destination_cidr_block = "10.31.0.0/16" },
          { destination_cidr_block = "0.0.0.0/0", blackhole = true },
        ]
      },
      us_prod_vpc = {
        vpc_id     = dependency.us_prod_vpc.outputs.vpc_id,
        subnet_ids = dependency.us_prod_vpc.outputs.private_subnets,
        tgw_routes = [
          { destination_cidr_block = "10.33.0.0/16" },
          { destination_cidr_block = "0.0.0.0/0", blackhole = true },
        ]
      },
      eu_stg_vpc = {
        vpc_id     = dependency.eu_stg_vpc.outputs.vpc_id,
        subnet_ids = dependency.eu_stg_vpc.outputs.private_subnets,
        tgw_routes = [
          { destination_cidr_block = "10.34.0.0/16" },
          { destination_cidr_block = "0.0.0.0/0", blackhole = true },
        ]
      },
      eu_prod_vpc = {
        vpc_id     = dependency.eu_prod_vpc.outputs.vpc_id,
        subnet_ids = dependency.eu_prod_vpc.outputs.private_subnets,
        tgw_routes = [
          { destination_cidr_block = "10.35.0.0/16" },
          { destination_cidr_block = "0.0.0.0/0", blackhole = true },
        ]
      },
    }
  }
)