# ==============================================================================
# Bootstrap Terraform Configuration
# ==============================================================================
# For GCP Free Tier Accounts:
#   - Leave org_id and billing_account empty (set to "")
#   - Set create_project to false
#   - Create GCP project manually and use its ID as project_id
# 
# For GCP Organization Accounts:
#   - Provide org_id (your GCP organization ID)
#   - Provide billing_account (your billing account ID)
#   - Set create_project to true (optional, can still be false)
# ==============================================================================

project_id        = "shared-vpc-host-project-492811"  # For free tier, set to your existing project ID; for org accounts, this will be created if create_project is true
project_number    = 399031706541
region            = "asia-southeast1"
org_id            = ""  # Leave empty for free tier, or provide org ID for org accounts
billing_account   = ""  # Leave empty for free tier, or provide billing account ID
github_org        = "Suman-IT"
github_repo       = "GCP-DEVOPS"
terraform_sa_name = "terraform-sa"
state_bucket_name = "gcp-devops-terraform-state"
create_project    = false  # Set to false for free tier (project already exists)