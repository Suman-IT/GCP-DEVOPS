// shared_vpc_attachment/main.tf

# Attach service project to shared VPC host project
resource "google_compute_shared_vpc_service_project" "service_project" {
  host_project    = var.host_project_id
  service_project = var.service_project_id
}

# Grant necessary roles to the service project to use shared VPC
resource "google_project_iam_member" "service_project_network_user" {
  project = var.host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${var.service_project_number}@cloudservices.gserviceaccount.com"
}

resource "google_project_iam_member" "service_project_security_admin" {
  project = var.host_project_id
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${var.service_project_number}@cloudservices.gserviceaccount.com"
}