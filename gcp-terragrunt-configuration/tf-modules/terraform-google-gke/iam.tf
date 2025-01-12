module "gke-k8s-iam" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  version  = "= 7.7.1"
  mode     = "additive"
  projects = [var.network_project_id]
  bindings = {
    "roles/compute.networkUser" = [
      "serviceAccount:${data.google_project.gke_project.number}@cloudservices.gserviceaccount.com",
      "serviceAccount:service-${data.google_project.gke_project.number}@container-engine-robot.iam.gserviceaccount.com"
    ],
    "roles/container.hostServiceAgentUser" = [
      "serviceAccount:service-${data.google_project.gke_project.number}@container-engine-robot.iam.gserviceaccount.com"
    ]
  }
}
