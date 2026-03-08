// envs/main.tf

provider "google" {
  project = var.project_id
  region  = var.region
}

// Create environment project (only if org_id is provided or create_project is true)
module "env_project" {
  source          = "../modules/projects"
  count           = var.create_project ? 1 : 0
  name            = "${var.environment} Project"
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

// Attach environment project to shared VPC
module "shared_vpc_attachment" {
  source                  = "../modules/shared_vpc_attachment"
  host_project_id         = var.host_project_id
  service_project_id      = var.project_id
  service_project_number  = var.service_project_number
}

// Create artifact registry in environment project
module "artifact" {
  source        = "../modules/artifact_registry"
  project_id    = var.project_id
  region        = var.region
  repository_id = var.artifact_repo_id
}

// Create GKE cluster in environment project
module "gke" {
  source             = "../modules/gke"
  project_id         = var.project_id
  region             = var.region
  cluster_name       = var.cluster_name
  network            = var.network_self_link
  subnetwork         = var.subnet_self_link
  node_service_account = var.node_service_account_email
  
  depends_on = [module.shared_vpc_attachment]
}

// ArgoCD application for the environment
module "argocd_app" {
  source = "../modules/argocd"

  name               = "demo-app-${var.environment}"
  repo_url           = var.gitops_repo_url
  path               = "gitops/${var.environment}"
  target_revision    = var.gitops_revision
  destination_server = module.gke.kubernetes_api_server
  destination_namespace = "default"
  value_files        = ["values-${var.environment}.yaml"]
}