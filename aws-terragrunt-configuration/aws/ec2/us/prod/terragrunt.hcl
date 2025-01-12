include "common" {
  path = find_in_parent_folders("common.hcl")
}

dependency "vpc" {
  config_path = "../../../vpc/us/prod"
}

terraform {
  source = "git::https://git@github.com/cloudon-one/aws-terraform-modules.git//aws-terraform-ec2?ref=dev"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(get_terragrunt_dir())
  location      = basename(dirname(get_terragrunt_dir()))
  resource      = basename(dirname(dirname(get_terragrunt_dir())))
  resource_vars = local.common_vars["Environments"]["${local.location}-${local.environment}"]["Resources"]["${local.resource}"]
}

inputs = {
  instances = [
    for instance in local.resource_vars["inputs"] :
    merge(instance, {
      subnet_id = dependency.vpc.outputs.private_subnets[0]
    })
  ]
}