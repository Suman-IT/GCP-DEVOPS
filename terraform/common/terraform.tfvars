# ==============================================================================
# Common Infrastructure Configuration (Shared VPC Host Project)
# This file contains values for shared resources (network, IAM)
#
# For GCP Free Tier:
#   - The network_project_id should already exist in GCP
#   - No need to provide org_id or billing_account
# ==============================================================================

network_project_id = "your-network-project-id"
region             = "us-central1"
network_name       = "shared-vpc"
github_org         = "your-github-org"
github_repo        = "GCP-DEVOPS"

subnets = [
  {
    name   = "subnet-01"
    cidr   = "10.0.0.0/24"
    region = "us-central1"
  }
]