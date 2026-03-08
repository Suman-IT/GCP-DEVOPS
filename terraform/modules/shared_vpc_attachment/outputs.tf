// shared_vpc_attachment/outputs.tf

output "service_project_attached" {
  description = "Indicates the service project is attached to shared VPC"
  value       = google_compute_shared_vpc_service_project.service_project.id
}