// envs/main.tf

provider "google" {
  project = var.project_id
  region  = var.region
}

// Enable required services for environment project (for existing projects)
resource "google_project_service" "env_services" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "serviceusage.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
  ])
  project = var.project_id
  service = each.key
}

// Grant terraform service account editor role in environment project
resource "google_project_iam_member" "terraform_sa_env" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:terraform-sa@${var.host_project_id}.iam.gserviceaccount.com"

  depends_on = [google_project_service.env_services]
}

// Create environment project (only if org_id is provided or create_project is true)
module "env_project" {
  source          = "../modules/projects"
  count           = var.create_project ? 1 : 0
  name            = "${var.environment} Project"
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
  services = {
    "cloudresourcemanager.googleapis.com" = true
    "compute.googleapis.com"              = true
    "serviceusage.googleapis.com"         = true
    "container.googleapis.com"            = true
    "artifactregistry.googleapis.com"     = true
    "iam.googleapis.com"                  = true
  }
}

// Attach environment project to shared VPC
module "shared_vpc_attachment" {
  source                 = "../modules/shared_vpc_attachment"
  host_project_id        = var.host_project_id
  service_project_id     = var.project_id
  service_project_number = var.service_project_number
}

// Create artifact registry in environment project
module "artifact" {
  source        = "../modules/artifact_registry"
  project_id    = var.project_id
  region        = var.region
  repository_id = var.artifact_repo_id
}

// Create GCE instance in environment project
module "gce" {
  source                = "../modules/gce"
  project_id            = var.project_id
  environment           = var.environment
  instance_name         = var.instance_name
  machine_type          = var.machine_type
  zone                  = var.zone
  boot_disk_image       = var.boot_disk_image
  boot_disk_size_gb     = var.boot_disk_size_gb
  boot_disk_type        = var.boot_disk_type
  network               = var.network_self_link
  subnetwork            = var.subnet_self_link
  enable_public_ip      = var.enable_public_ip
  service_account_email = var.node_service_account_email
  labels                = var.vm_labels
  metadata              = var.vm_metadata
  startup_script        = var.startup_script
  preemptible           = var.preemptible

  depends_on = [module.shared_vpc_attachment]
}

// Create GKE cluster in environment project
# module "gke" {
#   source             = "../modules/gke"
#   project_id         = var.project_id
#   region             = var.region
#   cluster_name       = var.cluster_name
#   network            = var.network_self_link
#   subnetwork         = var.subnet_self_link
#   node_service_account = var.node_service_account_email

#   depends_on = [module.shared_vpc_attachment]
# }

// ArgoCD application for the environment
# module "argocd_app" {
#   source = "../modules/argocd"

#   name               = "demo-app-${var.environment}"
#   repo_url           = var.gitops_repo_url
#   path               = "gitops/${var.environment}"
#   target_revision    = var.gitops_revision
#   destination_server = module.gke.kubernetes_api_server
#   destination_namespace = "default"
#   value_files        = ["values-${var.environment}.yaml"]
# }
