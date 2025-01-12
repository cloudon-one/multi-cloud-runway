terraform {
  source = "../../../../tf-modules//terraform-google-admin"
}

inputs = merge(local.resource_vars["inputs"], {
  admin_folder_name           = local.environment
  admin_project_name          = "${local.common_vars.common.labels.owner}-${local.resource}"
  admin_project_id            = "${local.common_vars.common.labels.owner}-${local.resource}-${local.common_vars.common.suffix}"
  admin_state_bucket          = "${local.common_vars.common.labels.owner}-${local.resource}-${local.common_vars.common.suffix}"
  admin_state_bucket_location = local.common_vars["envs"]["${local.environment}"]["region"]
  admin_random_project_id     = false
  org_parent_folder           = local.common_vars.common.root_folder
})

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.environment}"]["resources"]["${local.resource}"]
}

include {
  path = find_in_parent_folders()
}
