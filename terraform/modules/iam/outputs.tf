// iam/outputs.tf

output "service_account_email" {
  description = "Email of the created service account"
  value       = google_service_account.default.email
}

output "service_account_name" {
  description = "Name of the created service account"
  value       = google_service_account.default.name
}