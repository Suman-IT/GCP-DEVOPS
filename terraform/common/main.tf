// common/main.tf

provider "google" {
  project = var.network_project_id
  region  = var.region
}



// Create network resources in network project with Shared VPC Host enabled
module "network" {
  source                   = "../modules/network"
  project_id               = var.network_project_id
  name                     = var.network_name
  subnets                  = var.subnets
  enable_shared_vpc_host   = true
}

// Create IAM service account for GKE nodes
module "gke_node_sa" {
  source       = "../modules/iam"
  project_id   = var.network_project_id
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
  roles        = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/storage.objectViewer"
  ]
}







