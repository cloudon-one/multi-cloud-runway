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

variable "service_project_name" {
  description = "Service project name"
  type        = string
}

variable "service_projects" {
  description = "Map of service projects and their configs. Key = project_name Value = Project Factory Config. More info: https://github.com/terraform-google-modules/terraform-google-project-factory/tree/v9.0.0"
  type = map(object({
    folder_id                   = string
    lien                        = bool
    service_accounts            = list(string)
    active_apis                 = list(string)
    activate_api_identities     = list(object({ api = string, roles = list(string) }))
    random_project_id           = bool
    disable_dependent_services  = bool
    disable_services_on_destroy = bool
    shared_vpc_host_name        = string
    shared_vpc_subnets          = list(string)
    credentials_path            = string
    default_service_account     = string
  }))
  default = {}
}

variable "vpcs" {
  description = "This option allows creation of VPCs in the service project if shared VPC is not enough. Key = Project Name, Value = Network Config. More info: https://github.com/terraform-google-modules/terraform-google-network/tree/v2.5.0"
  type = map(object({
    network_name     = string
    subnets          = list(map(string))
    secondary_ranges = map(list(object({ range_name = string, ip_cidr_range = string })))
  }))
  default = {}
}

variable "kms_rings" {
  description = "Map of KMS keyrings with keys and owners"
  type = map(object({
    keyring        = string
    location       = string
    keys           = list(string)
    set_owners_for = list(string)
    owners         = list(string)
  }))
  default = {}
}
