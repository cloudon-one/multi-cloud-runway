# terraform-google-org-policies (G4-1)
# Uses the Org Policy v2 resource, which supports an explicit dry-run spec —
# the same mechanism VPC-SC uses (observe violations before enforcement).

locals {
  # folder-level enforcing instances: one per (folder, constraint)
  folder_policies = {
    for pair in flatten([
      for folder in var.enforcement_folders : [
        for name, cfg in var.policies : {
          key    = "${folder}|${name}"
          folder = folder
          name   = name
          cfg    = cfg
        } if cfg.enforce_folders
      ]
    ]) : pair.key => pair
  }

  org_dry_run_policies = { for name, cfg in var.policies : name => cfg if cfg.org_dry_run }
}

resource "google_org_policy_policy" "org_dry_run" {
  for_each = local.org_dry_run_policies

  name   = "${var.org_id}/policies/${each.key}"
  parent = var.org_id

  dry_run_spec {
    rules {
      enforce = each.value.type == "boolean" ? (each.value.enforce ? "TRUE" : "FALSE") : null

      dynamic "values" {
        for_each = each.value.type == "list" && !each.value.deny_all ? [1] : []
        content {
          allowed_values = each.value.allowed_values
          denied_values  = each.value.denied_values
        }
      }
    }
  }
}

resource "google_org_policy_policy" "folder_enforced" {
  for_each = local.folder_policies

  name   = "${each.value.folder}/policies/${each.value.name}"
  parent = each.value.folder

  spec {
    rules {
      enforce = each.value.cfg.type == "boolean" ? (each.value.cfg.enforce ? "TRUE" : "FALSE") : null
      deny_all = each.value.cfg.type == "list" && each.value.cfg.deny_all ? "TRUE" : null

      dynamic "values" {
        for_each = each.value.cfg.type == "list" && !each.value.cfg.deny_all ? [1] : []
        content {
          allowed_values = each.value.cfg.allowed_values
          denied_values  = each.value.cfg.denied_values
        }
      }
    }
  }
}
