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
  common_vars   = yamldecode(file(("vars.yaml")))
  environment   = basename(get_terragrunt_dir())
  location      = basename(dirname(get_terragrunt_dir()))
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
  }
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  provider "aws" {
  region = "${local.common_vars.common.default_region}"
}
EOF
}