# terraform-google-org-policies (G4-1)
# Each constraint can be deployed twice: dry-run at org scope and enforcing
# at explicit folder scopes (G4-3 pattern: observe org-wide, enforce on stg).

variable "org_id" {
  description = "Organization resource name, e.g. organizations/123456789012"
  type        = string
}

variable "enforcement_folders" {
  description = "Folder resource names (folders/NNN) where policies are ENFORCED"
  type        = list(string)
  default     = []
}

variable "policies" {
  description = <<-EOT
    Map of constraint name (e.g. compute.requireOsLogin) to behavior:
      type            "boolean" or "list"
      org_dry_run     create a dry-run policy at org scope (default true)
      enforce_folders create enforcing policies on enforcement_folders (default true)
      enforce         boolean constraints: enforce on/off (default true)
      deny_all        list constraints: deny all values
      allowed_values / denied_values  list constraints: explicit values
  EOT
  type = map(object({
    type            = string
    org_dry_run     = optional(bool, true)
    enforce_folders = optional(bool, true)
    enforce         = optional(bool, true)
    deny_all        = optional(bool, false)
    allowed_values  = optional(list(string))
    denied_values   = optional(list(string))
  }))

  validation {
    condition     = alltrue([for k, v in var.policies : contains(["boolean", "list"], v.type)])
    error_message = "policies[*].type must be \"boolean\" or \"list\"."
  }
}
