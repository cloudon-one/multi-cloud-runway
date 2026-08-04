# terraform-google-org-tags (G4-4): org-level tag keys/values with folder
# bindings for inheritance (environment, data-classification, compliance-scope).
# Controls: PCI-DSS 1.1 (workload classification), SOC2 CC6.1.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
  }
}

variable "org_id" {
  description = "Organization resource name, e.g. organizations/123456789012"
  type        = string
}

variable "tags" {
  description = "tag key => { description, values }"
  type = map(object({
    description = optional(string, "")
    values      = list(string)
  }))
}

variable "folder_bindings" {
  description = "folder resource name => { tag_key = tag_value } inherited bindings"
  type        = map(map(string))
  default     = {}
}

resource "google_tags_tag_key" "key" {
  for_each = var.tags

  parent      = var.org_id
  short_name  = each.key
  description = each.value.description
}

resource "google_tags_tag_value" "value" {
  for_each = {
    for pair in flatten([
      for key, cfg in var.tags : [
        for v in cfg.values : { id = "${key}/${v}", key = key, value = v }
      ]
    ]) : pair.id => pair
  }

  parent     = google_tags_tag_key.key[each.value.key].id
  short_name = each.value.value
}

resource "google_tags_tag_binding" "folder" {
  for_each = {
    for pair in flatten([
      for folder, binds in var.folder_bindings : [
        for key, value in binds : {
          id     = "${folder}|${key}"
          folder = folder
          tag    = "${key}/${value}"
        }
      ]
    ]) : pair.id => pair
  }

  parent    = "//cloudresourcemanager.googleapis.com/${each.value.folder}"
  tag_value = google_tags_tag_value.value[each.value.tag].id
}

output "tag_value_ids" {
  value = { for k, v in google_tags_tag_value.value : k => v.id }
}
