# ==============================================================================
# Dev Environment Configuration
# For GCP Free Tier:
#   - Create projects manually in GCP console
#   - Set create_project to false in main.tf or tfvars
#   - Leave org_id and billing_account empty
#   - Update project_id to your manually-created project ID
# For GCP Organization Accounts:
#   - Provide org_id, billing_account if using automatic project creation
# ==============================================================================

environment                 = "dev"
project_id                   = "your-dev-project-id"
region                       = "us-central1"
org_id                       = ""  # Leave empty for free tier
billing_account              = ""  # Leave empty for free tier
artifact_repo_id             = "dev-app-repo"
cluster_name                 = "dev-cluster"
network_self_link            = "projects/your-network-project-id/global/networks/shared-vpc"
subnet_self_link             = "projects/your-network-project-id/regions/us-central1/subnetworks/subnet-01"
node_service_account_email   = "gke-node-sa@your-network-project-id.iam.gserviceaccount.com"
gitops_repo_url              = "https://github.com/your-org/your-repo.git"
gitops_revision              = "main"
host_project_id              = "your-network-project-id"
service_project_number       = 123456789012
create_project               = false  # Set to false for free tier