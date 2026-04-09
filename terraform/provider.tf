// terraform/provider.tf

terraform {
  required_version = ">= 1.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.0"
    }
    argocd = {
      source  = "marcosnils/argocd"
      version = ">= 1.0"
    }
  }
}

provider "google" {
  impersonate_service_account = "terraform-sa@shared-vpc-host-project-492811.iam.gserviceaccount.com"
}

provider "google-beta" {
  impersonate_service_account = "terraform-sa@shared-vpc-host-project-492811.iam.gserviceaccount.com"
}

# Argocd provider uses the ArgoCD API server endpoint and an auth token
provider "argocd" {
  server_addr = var.argocd_server_addr
  auth_token  = var.argocd_auth_token
  insecure    = true
}
