terraform {
  source = "../../../../../tf-modules//terraform-google-iam-permissions"
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

dependency "service" {
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

dependencies {
  paths = [
    "../net-vpc",
    "../net-firewalls",
    "../svc-projects",
  ]
}

inputs = {
  net-vpc-attachments = {
    "${dependency.net-vpc.outputs.project_id}" = [
      dependency.service.outputs.projects["service"].project_id,
    ]
  }
  projects_iam = {
    "${dependency.net-vpc.outputs.project_id}" = {
      bindings = {
        "roles/container.hostServiceAgentUser" = [
          format("serviceAccount:service-%s@container-engine-robot.iam.gserviceaccount.com", dependency.service.outputs.projects["service"].project_number),
        ]
      }
    }
  }
  subnets_iam = {
    "${dependency.net-vpc.outputs.subnets["europe-west1/gke-subnet"].self_link}" = {
      bindings = {
        "roles/compute.networkUser" = [
          format("serviceAccount:service-%s@container-engine-robot.iam.gserviceaccount.com", dependency.service.outputs.projects["service"].project_number),
          format("serviceAccount:%s@cloudservices.gserviceaccount.com", dependency.service.outputs.projects["service"].project_number)
        ]
      }
    }
  }
}
