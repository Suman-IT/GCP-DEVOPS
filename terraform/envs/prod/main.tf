// envs/prod/main.tf

provider "google" {
  project = var.project_id
  region  = var.region
}

// Create prod project
module "prod_project" {
  source          = "../../modules/projects"
  name            = "Prod Project"
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
  services        = {
    "compute.googleapis.com"       = true
    "container.googleapis.com"     = true
    "artifactregistry.googleapis.com" = true
    "iam.googleapis.com"           = true
  }
}

// Create artifact registry in prod project
module "artifact" {
  source        = "../../modules/artifact_registry"
  project_id    = var.project_id
  region        = var.region
  repository_id = var.artifact_repo_id
}

// Create GKE cluster in prod project
module "gke" {
  source             = "../../modules/gke"
  project_id         = var.project_id
  region             = var.region
  cluster_name       = var.cluster_name
  network            = var.network_self_link
  subnetwork         = var.subnet_self_link
  node_service_account = var.node_service_account_email
}

module "argocd_app" {
  source = "../../modules/argocd"

  name               = "demo-app-prod"
  repo_url           = var.gitops_repo_url
  path               = "gitops/prod"
  target_revision    = var.gitops_revision
  destination_server = module.gke.kubernetes_api_server
  destination_namespace = "default"
  value_files        = ["values-prod.yaml"]
}
