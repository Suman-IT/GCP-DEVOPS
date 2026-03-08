// artifact_registry/variables.tf

variable "project_id" {
  description = "GCP project where repository will live"
  type        = string
}

variable "region" {
  description = "Region for the ARTIFACT_REGISTRY_REPO"
  type        = string
  default     = "us-central1"
}

variable "repository_id" {
  description = "Identifier for the repo (eg. my-app-repo)"
  type        = string
}
