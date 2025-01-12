locals {
  k8s_sa_gcp_name = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${local.k8s_given_name}]"
  k8s_given_name  = var.k8s_sa_name != null ? var.k8s_sa_name : var.name
}

resource "google_service_account" "cluster_service_account" {
  # GCP service account ids must be 6 - 30 chars matching regex ^[a-z](?:[-a-z0-9]{4,28}[a-z0-9])$
  # KSA do not have this naming restriction.
  account_id   = substr(var.name, 0, 30)
  display_name = substr("GCP SA bound to K8S SA ${var.k8s_sa_name}", 0, 100)
  project      = var.project_id
}

resource "google_service_account_iam_member" "main" {
  service_account_id = google_service_account.cluster_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.k8s_sa_gcp_name
}


resource "google_project_iam_member" "workload_identity_sa_bindings" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}