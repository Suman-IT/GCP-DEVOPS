# ==============================================================================
# Common Infrastructure Configuration (Shared VPC Host Project)
# This file contains values for shared resources (network, IAM)
# All resources created in Asia regions
# ==============================================================================

network_project_id = "shared-vpc-host-project-492811"
network_name       = "shared-vpc"
github_org         = "Suman-IT"
github_repo        = "GCP-DEVOPS"

subnets = [
  # Dev Environment Subnet - Singapore
  {
    name   = "subnet-dev"
    cidr   = "10.1.0.0/24"
    region = "asia-southeast1"
  },
  # QA Environment Subnet - Delhi
  {
    name   = "subnet-qa"
    cidr   = "10.2.0.0/24"
    region = "asia-south1"
  },
  # Prod Environment Subnet - Tokyo
  {
    name   = "subnet-prod"
    cidr   = "10.3.0.0/24"
    region = "asia-northeast1"
  }
]