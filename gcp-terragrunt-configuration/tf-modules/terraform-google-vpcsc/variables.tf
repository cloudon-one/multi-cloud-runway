# terraform-google-vpcsc (G4-5). DRY-RUN ONLY by design: the perimeter is
# created with use_explicit_dry_run_spec = true and no enforced spec.
# Promotion procedure: docs/RUNBOOKS/vpcsc-dryrun-to-enforce.md (out of scope
# for the pre-prod plan).

variable "org_id" {
  description = "Organization resource name, e.g. organizations/123456789012"
  type        = string
}

variable "policy_title" {
  description = "Access Context Manager policy title"
  type        = string
  default     = "default-policy"
}

variable "access_levels" {
  description = "name => conditions. Members are users/serviceAccounts/groups; ip_subnetworks are CIDRs."
  type = map(object({
    ip_subnetworks = optional(list(string), [])
    members        = optional(list(string), [])
  }))
  default = {}
}

variable "perimeter_name" {
  type    = string
  default = "stg_perimeter"
}

variable "perimeter_title" {
  type    = string
  default = "stg data perimeter (dry-run)"
}

variable "perimeter_project_numbers" {
  description = "Project numbers inside the perimeter (projects/N). Unknown until projects exist — placeholders pre-apply."
  type        = list(string)
}

variable "candidate_services" {
  description = "Union of enabled APIs across perimeter projects (derived by the stack from vars.yaml, not hand-maintained — G4-6)."
  type        = list(string)
}

variable "vpcsc_supported_services" {
  description = "VPC-SC-supported services to intersect candidates against."
  type        = list(string)
  default = [
    "aiplatform.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "dataflow.googleapis.com",
    "dns.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "redis.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "spanner.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
  ]
}

variable "ingress_policies" {
  description = "Ingress rules: identities/sources allowed into the perimeter (admin console, CI, GKE control plane)."
  type = list(object({
    from_identities    = optional(list(string), [])
    from_access_levels = optional(list(string), [])
    to_services        = optional(list(string), ["*"])
  }))
  default = []
}

variable "egress_policies" {
  description = "Egress rules: identities allowed out (artifact pulls, log export)."
  type = list(object({
    identities  = optional(list(string), [])
    to_services = optional(list(string), ["*"])
  }))
  default = []
}
