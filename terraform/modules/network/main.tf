// network/main.tf

resource "google_compute_network" "vpc" {
  name                    = var.name
  project                 = var.project_id
  auto_create_subnetworks = false
}

# Enable shared VPC host (if this is the host project)
resource "google_compute_shared_vpc_host_project" "host" {
  count   = var.enable_shared_vpc_host ? 1 : 0
  project = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  count        = length(var.subnets)
  name         = var.subnets[count.index].name
  ip_cidr_range = var.subnets[count.index].cidr
  region       = var.subnets[count.index].region
  network      = google_compute_network.vpc.id
  project      = var.project_id
}
