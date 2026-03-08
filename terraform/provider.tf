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

provider "google" {}
provider "google-beta" {}

# Argocd provider uses the ArgoCD API server endpoint and an auth token
provider "argocd" {
  server_addr = var.argocd_server_addr
  auth_token  = var.argocd_auth_token
  insecure    = true
}
