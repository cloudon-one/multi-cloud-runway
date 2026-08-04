# terraform-google-kms (G4-9)
# Controls: PCI-DSS 3.4/3.6, CIS GCP 1.10, HIPAA 164.312(a)(2)(iv).
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
  }
}
