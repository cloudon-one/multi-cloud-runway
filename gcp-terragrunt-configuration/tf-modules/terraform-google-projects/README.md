# Terraform Google Cloud Projects Module

This module creates and manages Google Cloud projects with service accounts, VPC networks, and KMS resources using the Google Project Factory.

## Overview

This module provides comprehensive project management with:

- **Service Projects**: Creates multiple projects using Project Factory
- **Service Accounts**: Dedicated service accounts per project
- **VPC Networks**: Optional VPC network creation per project
- **API Management**: Automatic API enablement
- **KMS Integration**: Optional KMS keyrings and keys
- **Organization Integration**: Proper folder and billing account assignment

## Usage

```hcl
module "projects" {
  source = "./tf-modules/terraform-google-projects"

  # Organization Configuration
  domain               = "example.com"
  billing_account      = "012345-678901-234567"
  service_project_name = "my-service-project"
  environment          = "production"

  # Service Projects
  service_projects = {
    service = {
      folder_id                   = "folders/123456789012"
      lien                        = true
      default_service_account     = "deprivilege"
      service_accounts           = ["gke-sa", "sql-sa"]
      apis                       = ["container.googleapis.com", "sqladmin.googleapis.com"]
      shared_vpc_host_name       = "host-project-12345"
      shared_vpc_subnets         = ["projects/host/global/networks/vpc/subnetworks/subnet1"]
    }
  }

  # VPC Networks (Optional)
  vpcs = {
    main = {
      network_name                           = "main-vpc"
      auto_create_subnetworks               = false
      routing_mode                          = "REGIONAL"
      delete_default_internet_gateway_routes = false
      description                           = "Main VPC network"
      mtu                                   = 1460
      project_id                            = "my-project"
      shared_vpc_host                       = true
      subnets = [{
        subnet_name           = "main-subnet"
        subnet_ip            = "10.0.1.0/24"
        subnet_region        = "us-east1"
        subnet_private_access = true
        subnet_flow_logs     = true
      }]
      secondary_ranges = {
        main-subnet = [{
          range_name    = "pods"
          ip_cidr_range = "10.1.0.0/16"
        }]
      }
    }
  }

  # KMS Configuration (Optional)
  kms_rings = {
    app-secrets = {
      keyring        = "app-secrets-ring"
      location       = "global"
      keys           = ["app-key", "db-key"]
      set_owners_for = ["app-key"]
      owners         = ["user:admin@example.com"]
    }
  }
}
```

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `domain` | Organization domain | `string` |
| `billing_account` | Billing account ID | `string` |
| `service_project_name` | Base name for service projects | `string` |
| `environment` | Environment identifier | `string` |

### Service Projects Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `service_projects` | Map of service projects to create | `map(object)` | `{}` |

#### Service Project Object Structure
```hcl
service_projects = {
  project_name = {
    folder_id                   = string
    lien                        = bool
    default_service_account     = string
    service_accounts           = list(string)
    apis                       = list(string)
    shared_vpc_host_name       = string
    shared_vpc_subnets         = list(string)
  }
}
```

### Optional Configurations

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `vpcs` | VPC network configurations | `map(object)` | `{}` |
| `kms_rings` | KMS keyring configurations | `map(object)` | `{}` |

## Resources Created

### Project Resources
- `module.service_project`: Google Project Factory instances
- `module.active_apis`: API enablement per project
- `google_service_account`: Service accounts per project

### Optional Resources
- `module.vpc`: VPC networks (if configured)
- `module.kms_rings`: KMS keyrings and keys (if configured)

## Features

- **Multi-Project Management**: Create and manage multiple related projects
- **Shared VPC Integration**: Automatic shared VPC service project attachment
- **Service Account Management**: Dedicated service accounts with proper naming
- **API Management**: Bulk API enablement across projects
- **KMS Integration**: Encryption key management per project
- **Organization Alignment**: Proper folder structure and billing integration

## Outputs

| Name | Description |
|------|-------------|
| `projects` | Map of created project details |
| `service_accounts` | Map of created service accounts |
| `vpcs` | Map of created VPC networks |
| `kms_keys` | Map of created KMS keys |

---

**⚠️ Production Projects**: This module creates billable GCP projects. Review configuration carefully before deployment.