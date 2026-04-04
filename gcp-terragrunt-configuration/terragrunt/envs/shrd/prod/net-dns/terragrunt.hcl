terraform {
  source = "../../../../../tf-modules//terraform-google-dns"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  folder        = basename(dirname(dirname(get_terragrunt_dir())))
  folder_id     = "${local.folder}/${local.environment}"
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["resources"]["${local.resource}"]
}

include "root" {
  path = find_in_parent_folders()
}

dependency "net-vpc" {
  config_path = "../net-vpc"
  mock_outputs = {
    project_id         = "mock-project"
    network_self_link  = "projects/mock/global/networks/mock"
    network_name       = "mock-network"
    subnets_self_links = ["projects/mock/regions/mock/subnetworks/mock"]
    subnets = {
      "europe-west1/gke-subnet" = {
        self_link = "projects/mock/regions/europe-west1/subnetworks/gke-subnet"
        name      = "gke-subnet"
        region    = "europe-west1"
      }
      "us-east1/gke-subnet" = {
        self_link = "projects/mock/regions/us-east1/subnetworks/gke-subnet"
        name      = "gke-subnet"
        region    = "us-east1"
      }
      "$REGION/$SUBNET" = {
        self_link = "projects/mock/regions/mock/subnetworks/mock"
        name      = "mock-subnet"
        region    = "mock-region"
      }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = merge(local.resource_vars["inputs"], {
  project_id = dependency.net-vpc.outputs.project_id
  private_visibility_config_networks = [
    dependency.net-vpc.outputs.network_self_link
  ]
})
