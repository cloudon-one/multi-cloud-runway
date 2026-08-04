# terraform-google-vpcsc (G4-5): access policy, access levels, and a service
# perimeter that is DRY-RUN ONLY (use_explicit_dry_run_spec = true, no
# enforced spec). Violations appear in Cloud Logging with
# protoPayload.metadata.dryRun=true instead of being blocked.

locals {
  restricted_services = sort(tolist(setintersection(
    toset(var.candidate_services),
    toset(var.vpcsc_supported_services),
  )))
  perimeter_resources = [for n in var.perimeter_project_numbers : "projects/${n}"]
}

resource "google_access_context_manager_access_policy" "policy" {
  parent = var.org_id
  title  = var.policy_title
}

resource "google_access_context_manager_access_level" "level" {
  for_each = var.access_levels

  parent = "accessPolicies/${google_access_context_manager_access_policy.policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.policy.name}/accessLevels/${each.key}"
  title  = each.key

  basic {
    conditions {
      ip_subnetworks = each.value.ip_subnetworks
      members        = each.value.members
    }
  }
}

resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.policy.name}/servicePerimeters/${var.perimeter_name}"
  title  = var.perimeter_title

  # Explicit dry-run: spec observed, never enforced (promotion is a separate,
  # human-run procedure — see runbook).
  use_explicit_dry_run_spec = true

  spec {
    resources           = local.perimeter_resources
    restricted_services = local.restricted_services

    dynamic "ingress_policies" {
      for_each = var.ingress_policies
      content {
        ingress_from {
          identities = ingress_policies.value.from_identities
          sources {
            access_level = length(ingress_policies.value.from_access_levels) > 0 ? google_access_context_manager_access_level.level[ingress_policies.value.from_access_levels[0]].name : "*"
          }
        }
        ingress_to {
          resources = ["*"]
          dynamic "operations" {
            for_each = ingress_policies.value.to_services
            content {
              service_name = operations.value
            }
          }
        }
      }
    }

    dynamic "egress_policies" {
      for_each = var.egress_policies
      content {
        egress_from {
          identities = egress_policies.value.identities
        }
        egress_to {
          resources = ["*"]
          dynamic "operations" {
            for_each = egress_policies.value.to_services
            content {
              service_name = operations.value
            }
          }
        }
      }
    }
  }

  lifecycle {
    # a perimeter must never flip to enforced via drift/refactor — promotion
    # is the documented runbook procedure only
    ignore_changes = [status]
  }
}
