// gke/main.tf

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork

  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name     = "default-pool"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name

  node_config {
    machine_type    = var.machine_type
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    service_account = var.node_service_account
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  initial_node_count = var.node_count
}
