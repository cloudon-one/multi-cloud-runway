variable "host_project_name" {
  description = "Host Project Name suffix. Project ID will be {var.host_project_name}-{var.geo}-{var.environment}"
  type        = string
}

variable "billing_account" {
  description = "Billing Account"
  type        = string
}

variable "domain" {
  description = "Organization domain"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "subnets" {
  type        = list(map(string))
  description = "The list of subnets being created"
  default     = []
}

variable "subnets_beta" {
  type        = list(map(string))
  description = "The list of subnets being created. For beta features"
  default     = []
}

variable "secondary_ranges" {
  type        = map(list(object({ range_name = string, ip_cidr_range = string })))
  description = "Secondary ranges that will be used in some of the subnets"
  default     = {}
}

variable "network_name" {
  description = "The name of the network being created"
  type        = string
}

variable "active_apis" {
  description = "List of API to activate on the host project"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "logging.googleapis.com",
  ]
}

variable "folder_id" {
  description = "If specified, the host project will be created under this folder"
  type        = string
  default     = null
}

variable "lien" {
  description = "If set to false the lien is disabled"
  type        = bool
  default     = false
}

variable "default_service_account" {
  description = "Project default service account setting: can be one of `delete`, `deprivilege`, `disable`, or `keep`."
  default     = "deprivilege"
  type        = string
}

variable "service_accounts" {
  description = "List of service accounts to be created in the host project"
  type        = list(string)
  default     = []
}

variable "routes" {
  description = "List of routes being created in this VPC"
  type        = list(map(string))
  default     = []
}

variable "credentials_path" {
  description = "Path to a service account credentials file with rights to run the Project Factory. If this file is absent Terraform will fall back to Application Default Credentials."
  type        = string
  default     = ""
}

variable "cloud_nats" {
  description = "Cloud Nat Setup"
  type = map(object({
    router_name                        = string
    router_asn                         = string
    source_subnetwork_ip_ranges_to_nat = string
    log_config_enable                  = bool
    log_config_filter                  = string
    subnetworks = list(object({
      name                     = string,
      source_ip_ranges_to_nat  = list(string)
      secondary_ip_range_names = list(string)
    }))
  }))
  default = {}
}
