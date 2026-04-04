terraform {
  source = "../../../../../tf-modules//terraform-google-gke"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "host_project" {
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
dependency "gke_project" {
  config_path = "../svc-projects"
  mock_outputs = {
    projects = {
      "service" = {
        project_id     = "mock-service-project"
        project_number = "000000000000"
      }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  folder        = basename(dirname(dirname(get_terragrunt_dir())))
  folder_id     = "${local.folder}/${local.environment}"
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["resources"]["${local.resource}"]

}

inputs = merge(local.resource_vars["inputs"], {
  project_id         = dependency.gke_project.outputs.projects["service"].project_id
  region             = dependency.host_project.outputs.subnets["europe-west1/gke-subnet"].region
  network            = dependency.host_project.outputs.network_name
  network_project_id = dependency.host_project.outputs.project_id
  subnetwork         = dependency.host_project.outputs.subnets["europe-west1/gke-subnet"].name
  identity_namespace = "${dependency.gke_project.outputs.projects["service"].project_id}.svc.id.goog"
})
