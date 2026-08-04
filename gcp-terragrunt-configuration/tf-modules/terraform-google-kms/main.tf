# terraform-google-kms (G4-9)

locals {
  region_keys = {
    for pair in setproduct(var.regions, keys(var.keys)) :
    "${pair[0]}/${pair[1]}" => {
      region = pair[0]
      key    = pair[1]
      cfg    = var.keys[pair[1]]
    }
  }
}

resource "google_kms_key_ring" "ring" {
  for_each = toset(var.regions)

  project  = var.project_id
  name     = "${var.keyring_prefix}-${each.value}"
  location = each.value
}

resource "google_kms_crypto_key" "key" {
  # checkov:skip=CKV_GCP_43:rotation_period is always set — the variable type
  # defaults it to 7776000s (90 days) and vars.yaml declares it explicitly;
  # checkov cannot resolve the for_each/local indirection statically.
  for_each = local.region_keys

  name            = each.value.key
  key_ring        = google_kms_key_ring.ring[each.value.region].id
  rotation_period = each.value.cfg.rotation_period
  purpose         = "ENCRYPT_DECRYPT"

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = var.protection_level
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_member" "service_agent" {
  for_each = {
    for entry in flatten([
      for rk, spec in local.region_keys : [
        for agent in spec.cfg.service_agents : {
          key    = "${rk}|${agent}"
          rk     = rk
          member = agent
        }
      ]
    ]) : entry.key => entry
  }

  crypto_key_id = google_kms_crypto_key.key[each.value.rk].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = each.value.member
}
