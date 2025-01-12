variable "organizations_iam" {
  description = "Structure describing role bindings for organizations. Mapping is done via domain. Example: {example.com = {bindings = {roles/owner = [\"user:ab@example.com\"]}}}"
  type = map(object({
    bindings = map(list(string))
  }))
  default = {}
}

variable "folders_iam" {
  description = "Structure describing role bindings for folders"
  type = map(object({
    bindings = map(list(string))
  }))
  default = {}
}

variable "projects_iam" {
  description = "Structure describing role bindings for projects"
  type = map(object({
    bindings = map(list(string))
  }))
  default = {}
}

variable "subnets_iam" {
  description = "Structure describing role bindings for subnets. Subnets have to be defined as self_links. Example: {\"projects/robin-sandbox-260523/regions/us-west1/subnetworks/gke-subnet\" = {bindings = {roles/compute.networkAdmin = [\"user:ab@example.com\"]}}}"
  type = map(object({
    bindings = map(list(string))
  }))
  default = {}
}

variable "storage_buckets_iam" {
  description = "Structure describing role bindings for storage buckets."
  type = map(object({
    bindings = map(list(string))
  }))
  default = {}
}

variable "service_accounts_iam" {
  description = "Structure describing role bindings for service accounts. Example: { \"terraform-eu-stg@administration-4082.iam.gserviceaccount.com\" = {bindings = {roles/iam.serviceAccountTokenCreator = [\"user:ab@example.com\"]}, project = \"admin-123\"}}"
  type = map(object({
    bindings = map(list(string)),
    project  = string
  }))
  default = {}
}

variable "workload_identity_iam" {
  description = ""
  type = map(object({
    namespace   = string,
    k8s_sa_name = string
    project     = string,
    roles       = list(string)
  }))
  default = {}
}

variable "shared_vpc_attachments" {
  description = "Map of the projects that should be attached to host project. Key = Host Project, Value = List of service projects"
  type        = map(list(string))
  default     = {}
}
