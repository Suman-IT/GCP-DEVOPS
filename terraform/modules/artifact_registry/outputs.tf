// artifact_registry/outputs.tf

output "repository" {
  value = google_artifact_registry_repository.repo.name
}
