// bootstrap/main.tf

# Optional project creation using projects module if org_id and billing_account provided
# If the project already exists, set create_project = false and provide project_id manually

module "common_project" {
  source          = "../modules/projects"
  count           = var.create_project ? 1 : 0
  name            = "Common Project"
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account
  services        = {
    "cloudresourcemanager.googleapis.com" = true
    "compute.googleapis.com"       = true
    "serviceusage.googleapis.com"  = true
    "servicenetworking.googleapis.com" = true
    "container.googleapis.com"     = true
    "artifactregistry.googleapis.com" = true
    "iam.googleapis.com"           = true
    "storage.googleapis.com"       = true
    "iamcredentials.googleapis.com" = true
    "sts.googleapis.com"           = true
  }
}

# enable required services for existing project
resource "google_project_service" "required" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ])
  project = var.project_id
  service = each.key
}

# bucket for Terraform state
resource "google_storage_bucket" "tf_state" {
  name     = var.state_bucket_name
  location = var.region
  project  = var.project_id

  uniform_bucket_level_access = true
  force_destroy               = true

  versioning {
    enabled = true
  }

  labels = {
    purpose = "terraform-state"
    owner   = "devops"
  }
}

# terraform service account
resource "google_service_account" "terraform_sa" {
  project      = var.project_id
  account_id   = var.terraform_sa_name
  display_name = "Terraform Service Account"
}

# grant broad roles to terraform SA
resource "google_project_iam_member" "terraform_sa_roles" {
  for_each = toset([
    "roles/editor",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

locals {
  terraform_sa_managed_projects = distinct(concat([var.project_id], var.additional_project_ids))
  terraform_sa_admin_roles = toset([
    "roles/resourcemanager.projectIamAdmin",
    "roles/compute.xpnAdmin",
  ])
}

# grant cross-project admin roles needed for environment IAM updates and Shared VPC attachment
resource "google_project_iam_member" "terraform_sa_project_admin_roles" {
  for_each = {
    for entry in flatten([
      for project_id in local.terraform_sa_managed_projects : [
        for role in local.terraform_sa_admin_roles : {
          key        = "${project_id}:${role}"
          project_id = project_id
          role       = role
        }
      ]
    ]) : entry.key => entry
  }

  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

# grant organization-level roles (if org_id is provided)
resource "google_organization_iam_member" "terraform_sa_org_roles" {
  for_each = var.org_id != "" ? toset([
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.projectIamAdmin",
    "roles/compute.xpnAdmin",
    "roles/iam.securityAdmin",
  ]) : toset([])
  
  org_id = var.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.terraform_sa.email}"
}

# workload identity pool and provider
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
  project                   = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  description                        = "Workload Identity Provider for GitHub Actions"
  project                            = var.project_id

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_condition = "attribute.repository == \"${var.github_org}/${var.github_repo}\""
}

# bind terraform SA to WIF pool
resource "google_service_account_iam_binding" "terraform_sa_wif" {
  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/attribute.repository/${var.github_org}/${var.github_repo}"
  ]
}
