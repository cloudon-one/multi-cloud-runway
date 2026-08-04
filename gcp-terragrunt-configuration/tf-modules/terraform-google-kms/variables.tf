# terraform-google-kms (G4-9): keyrings per region, keys per service,
# rotation from vars, IAM bindings for service agents.

variable "project_id" {
  description = "Project that owns the keyrings"
  type        = string
}

variable "regions" {
  description = "Regions to create a keyring in"
  type        = list(string)
}

variable "keyring_prefix" {
  description = "Keyring name prefix; final name <prefix>-<region>"
  type        = string
}

variable "keys" {
  description = <<-EOT
    Service key definitions, created in every regional keyring:
      rotation_period   e.g. "7776000s" (90 days)
      service_agents    IAM members granted roles/cloudkms.cryptoKeyEncrypterDecrypter.
                        Usually empty at plan time — service agents need project
                        numbers that exist only post-apply; CMEK_WIRING.md carries
                        the post-apply commands (G4-11).
  EOT
  type = map(object({
    rotation_period = optional(string, "7776000s") # 90 days (CKV_GCP_43 ceiling)
    service_agents  = optional(list(string), [])
  }))
}

variable "protection_level" {
  type    = string
  default = "SOFTWARE"
}
