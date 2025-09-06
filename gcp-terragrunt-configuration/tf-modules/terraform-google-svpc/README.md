# Terraform Google Cloud Shared VPC Module

This module creates and manages Google Cloud Shared VPC networks with host projects, service project attachments, and comprehensive networking configuration.

## Overview

This module provides Shared VPC management with:

- **Host Project**: Dedicated project for network resources
- **VPC Network**: Production-ready VPC with subnets and secondary ranges
- **Service Project Attachments**: Automatic service project association
- **Network Security**: Firewall rules and private Google access
- **Subnet Management**: Regional subnets with secondary IP ranges for GKE

## Usage

```hcl
module "shared_vpc" {
  source = "./tf-modules/terraform-google-svpc"

  # Host Project Configuration
  project_name        = "shared-vpc-host"
  billing_account     = "012345-678901-234567"
  folder_id          = "folders/123456789012"
  environment        = "production"

  # VPC Configuration
  network_name = "shared-production-vpc"
  routing_mode = "REGIONAL"

  # Subnets
  subnets = [
    {
      subnet_name           = "gke-subnet"
      subnet_ip            = "10.0.1.0/24"
      subnet_region        = "us-east1"
      subnet_private_access = true
      subnet_flow_logs     = true
    }
  ]

  # Secondary Ranges for GKE
  secondary_ranges = {
    gke-subnet = [
      {
        range_name    = "pods"
        ip_cidr_range = "10.1.0.0/16"
      },
      {
        range_name    = "services"
        ip_cidr_range = "10.2.0.0/20"
      }
    ]
  }

  # Service Projects to Attach
  service_projects = ["service-project-1", "service-project-2"]
}
```

## Features

- **Centralized Network Management**: Single host project manages all networking
- **Cross-Project Resource Sharing**: Service projects can use host project networks
- **Scalable Architecture**: Support for multiple service projects and environments
- **Security Controls**: Network-level security with proper IAM integration
- **GKE Ready**: Pre-configured secondary ranges for Kubernetes pods and services

---

**⚠️ Shared VPC Host**: This module creates the central networking infrastructure. Changes affect all attached service projects.