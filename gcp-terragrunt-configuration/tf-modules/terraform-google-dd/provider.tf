terraform {
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = ">= 1.9"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 3.30"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
  required_version = ">= 0.12.26"
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}