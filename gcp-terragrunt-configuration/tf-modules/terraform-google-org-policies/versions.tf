# terraform-google-org-policies (G4-1)
# Controls: CIS GCP 1.x, PCI-DSS 7.x, SOC2 CC6.1 — org-level guardrails.
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
  }
}
