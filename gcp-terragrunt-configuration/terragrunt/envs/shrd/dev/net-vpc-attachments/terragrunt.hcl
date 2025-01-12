terraform {
  source = "../../../../../tf-modules//terraform-google-iam-permissions"
}

include {
  path = find_in_parent_folders()
}

dependency "net-vpc" {
  config_path = "../net-vpc"
}

dependency "service" {
  config_path = "../svc-projects"
}

dependencies {
  paths = [
    "../net-vpc",
    "../net-iam-permissions",
    "../net-firewalls",
    "../svc-projects",
    "../svc-iam-permissions",
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
    "${dependency.net-vpc.outputs.subnets["$rEGION/$SUBNET"].self_link}" = {
      bindings = {
        "roles/compute.networkUser" = [
          format("serviceAccount:service-%s@container-engine-robot.iam.gserviceaccount.com", dependency.service.outputs.projects["service"].project_number),
          format("serviceAccount:%s@cloudservices.gserviceaccount.com", dependency.service.outputs.projects["service"].project_number)
        ]
      }
    }
  }
}
