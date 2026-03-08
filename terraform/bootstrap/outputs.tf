output "project_id" {
  value = var.project_id
}

output "project_number" {
  value = var.project_number
}

output "state_bucket" {
  value = google_storage_bucket.tf_state.name
}

output "terraform_sa_email" {
  value = google_service_account.terraform_sa.email
}

output "workload_identity_pool_id" {
  value = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
}

output "workload_identity_provider_id" {
  value = google_iam_workload_identity_pool_provider.github_provider.workload_identity_pool_provider_id
}