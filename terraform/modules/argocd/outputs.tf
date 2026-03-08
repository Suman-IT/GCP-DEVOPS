// argocd/outputs.tf

output "application_name" {
  value = argocd_application.app.metadata[0].name
}

output "project_name" {
  value = argocd_project.project.metadata[0].name
}

output "repository_url" {
  value = argocd_repository.repo.repo
}
