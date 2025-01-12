terraform {
  extra_arguments "common" {
    commands = get_terraform_commands_that_need_vars()
  }
  extra_arguments "non-interactive" {
    commands = [
      "apply"
    ]
    arguments = [
      "-auto-approve",
      "-compact-warnings"
    ]
  }
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.environment}"]["resources"]["${local.resource}"]
}

#remote_state {
#  backend = "gcs"
#  config = {
#    bucket               = "${local.common_vars.common.labels.owner}-admin-${local.common_vars.common.suffix}"
#    prefix               = "envs/global/${path_relative_to_include()}"
#    skip_bucket_creation = true
#  }
#  generate = {
#    path      = "backend.tf"
#    if_exists = "overwrite"
#  }
#}

skip = true
