terraform {
  source = "../../../../../tf-modules//terraform-google-projects"
}

inputs = merge(local.resource_vars["inputs"], {

  service_projects = {
    service = merge(local.resource_vars["inputs"]["service_projects"]["service"], {
      folder_id            = dependency.admin.outputs.folders["${local.folder_id}"].name
      shared_vpc_host_name = dependency.net-vpc.outputs.project_id
      shared_vpc_subnets   = dependency.net-vpc.outputs.subnets_self_links
    })
  }
  environment = local.environment
})

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  environment   = basename(dirname(get_terragrunt_dir()))
  folder        = basename(dirname(dirname(get_terragrunt_dir())))
  folder_id     = "${local.folder}/${local.environment}"
  resource      = basename(get_terragrunt_dir())
  resource_vars = local.common_vars["envs"]["${local.folder}"]["${local.environment}"]["resources"]["${local.resource}"]
}

dependencies { paths = [
  "../net-vpc"
] }

dependency "admin" {
  config_path = "../../../global/admin"
  mock_outputs = {
    folders = {
      "dev/eu" = {
        name   = "folders/mock-dev-eu"
        parent = "organizations/mock"
      }
      "prod/eu" = {
        name   = "folders/mock-prod-eu"
        parent = "organizations/mock"
      }
      "prod/us" = {
        name   = "folders/mock-prod-us"
        parent = "organizations/mock"
      }
      "shrd/dev" = {
        name   = "folders/mock-shrd-dev"
        parent = "organizations/mock"
      }
      "shrd/prod" = {
        name   = "folders/mock-shrd-prod"
        parent = "organizations/mock"
      }
      "stg/eu" = {
        name   = "folders/mock-stg-eu"
        parent = "organizations/mock"
      }
      "mgmt" = {
        name   = "folders/mock-mgmt"
        parent = "organizations/mock"
      }
    }
    network_self_link = "projects/mock/global/networks/mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
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

include "root" {
  path = find_in_parent_folders()
}
