terraform {
  extra_arguments "common" {
    commands = get_terraform_commands_that_need_vars()
  }
  extra_arguments "non-interactive" {
    commands = [
      "apply"

    ]
    arguments = [
      "-compact-warnings", 
    ]
  }
}

locals {
  common_vars     = yamldecode(file("vars.yaml"))
  environment     = basename(get_terragrunt_dir())
  location        = basename(dirname(get_terragrunt_dir()))
  provider_region = local.location == "eu" ? local.common_vars.common.eu_region : local.common_vars.common.default_region
}

remote_state {
    backend = "s3"
    generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.common_vars.common.owner}-${local.common_vars.common.provider}-admin-${local.common_vars.common.statebucketsuffix}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.common_vars.common.default_region
    encrypt        = true
    dynamodb_table = "${local.common_vars.common.owner}-${local.common_vars.common.provider}-admin-tf-locks"
  }
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.provider_region}"

  default_tags {
    tags = {
      owner     = "cloudon"
      terraform = "true"
    }
  }
}
EOF
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }
}
EOF
}