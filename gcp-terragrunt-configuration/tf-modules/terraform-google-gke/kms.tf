data "google_project" "gke_project" {
  project_id = var.project_id
}

resource "random_string" "kms_key_suffix" {
  count   = var.database_encryption ? 1 : 0
  length  = 4
  special = false
}

resource "google_kms_key_ring" "application_secrets_key_ring" {
  count    = var.database_encryption ? 1 : 0
  project  = var.project_id
  location = var.region
  name     = "application-secrets-key-ring-${random_string.kms_key_suffix.0.result}"
}

resource "google_kms_crypto_key" "application_secretes_key" {
  count           = var.database_encryption ? 1 : 0
  key_ring        = google_kms_key_ring.application_secrets_key_ring.0.self_link
  name            = "application-secrets-key-${random_string.kms_key_suffix.0.result}"
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = var.application_secrets_key_rotation_period
}

resource "google_kms_crypto_key_iam_member" "gke_sa_iam_permissions" {
  count         = var.database_encryption ? 1 : 0
  crypto_key_id = google_kms_crypto_key.application_secretes_key.0.self_link
  member        = "serviceAccount:service-${data.google_project.gke_project.number}@container-engine-robot.iam.gserviceaccount.com"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

locals {
  default_database_encryption = [{
    state    = "DECRYPTED"
    key_name = ""
  }]
  database_encryption = var.database_encryption ? [{
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.application_secretes_key.0.self_link
  }] : local.default_database_encryption
}
