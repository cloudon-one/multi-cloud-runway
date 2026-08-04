# terraform-google-vpcsc (G4-5)
# Controls: PCI-DSS 1.3 (data perimeter), SOC2 CC6.6, HIPAA 164.312(e)(1).
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
  }
}
