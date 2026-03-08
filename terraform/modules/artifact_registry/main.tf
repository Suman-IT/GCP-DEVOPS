// artifact_registry/main.tf

resource "google_artifact_registry_repository" "repo" {
  provider     = google-beta
  project      = var.project_id
  location     = var.region
  repository_id = var.repository_id
  format       = "DOCKER"
  description  = "Container images for application"
}
