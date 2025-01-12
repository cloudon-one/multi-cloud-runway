terraform {
  source = "../../../../../tf-modules//terraform-google-dns"
}

locals {
common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
environment   = basename(dirname(get_terragrunt_dir()))
resource      = basename(get_terragrunt_dir())
resource_vars = local.common_vars["envs"]["${local.environment}"]["resources"]["${local.resource}"]

inputs = merge(local.resource_vars["inputs"], {
  private_visibility_config_networks = [
    dependency.admin.outputs.network_self_link
  ]
})

include {
  path = find_in_parent_folders()
}

dependency "admin" {
  config_path = "../admin"
}
