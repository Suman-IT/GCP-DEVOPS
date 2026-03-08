variable "project_id" {
  description = "Common project ID where resources will be bootstrapped"
  type        = string
}

variable "project_number" {
  description = "Numeric ID of the project (used for WIF bindings)"
  type        = number
  default     = 0
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "us-central1"
}

variable "org_id" {
  description = "Organization ID (for project creation if needed)"
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "Billing account ID (for project creation)"
  type        = string
  default     = ""
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "terraform_sa_name" {
  description = "Name of the Terraform service account"
  type        = string
  default     = "terraform-sa"
}

variable "state_bucket_name" {
  description = "GCS bucket name for storing Terraform state"
  type        = string
}

variable "create_project" {
  description = "Whether to provision the common project using Terraform module (set to false for free tier if project already exists)"
  type        = bool
  default     = false
}
