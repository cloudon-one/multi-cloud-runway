variable "org_id" {
  type        = string
  description = "The ID of the AWS Organization"
}

variable "org_units" {
  type = list(object({
    name      = string
    parent_id = string
  }))
  description = "List of organizational units to be created"
}

variable "accounts" {
  type = map(object({
    account_name  = string
    account_email = string
    ou            = string
  }))
  description = "Map of AWS accounts to be created"
}