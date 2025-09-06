# Terraform Google Cloud IAM Permissions Module

This module manages Google Cloud IAM permissions across organizations, folders, projects, service accounts, and other resources with workload identity integration.

## Overview

- **Multi-Level IAM**: Organization, folder, project, and resource-level permissions
- **Service Account Management**: IAM bindings for service accounts  
- **Workload Identity**: Kubernetes service account integration
- **Storage IAM**: Bucket-level permissions management
- **Network IAM**: Subnet and VPC permissions

## Usage

```hcl
module "iam_permissions" {
  source = "./tf-modules/terraform-google-iam-permissions"

  # Project IAM
  project_iam_bindings = {
    "my-project" = [
      {
        role    = "roles/compute.viewer"
        members = ["user:admin@example.com"]
      }
    ]
  }

  # Service Account IAM
  service_account_iam = {
    "my-sa@my-project.iam.gserviceaccount.com" = [
      {
        role    = "roles/iam.workloadIdentityUser"
        members = ["serviceAccount:my-project.svc.id.goog[namespace/ksa]"]
      }
    ]
  }

  # Folder IAM
  folder_iam_bindings = {
    "folders/123456789012" = [
      {
        role    = "roles/resourcemanager.folderViewer"
        members = ["group:engineers@example.com"]
      }
    ]
  }
}
```

## Features

- **Comprehensive IAM Management**: Support for all GCP resource types
- **Workload Identity Ready**: Pre-configured for GKE workload identity
- **Batch Operations**: Efficient bulk IAM binding management
- **Least Privilege**: Granular permission control
- **Audit Trail**: All IAM changes tracked through Terraform state

---

**⚠️ Security Critical**: IAM changes affect access control. Review all permissions carefully.