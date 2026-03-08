// envs/dev/variables.tf

variable "project_id" {
  description = "GCP project ID for the dev environment"
  type        = string
}

variable "region" {
  description = "Region for resources"
  type        = string
}

variable "org_id" {
  description = "Organization ID under which project will be created"
  type        = string
}

variable "billing_account" {
  description = "Billing account ID to attach to the project"
  type        = string
}

variable "artifact_repo_id" {
  description = "Artifact Registry repo id"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "network_self_link" {
  description = "Self link of the shared VPC network"
  type        = string
}

variable "subnet_self_link" {
  description = "Self link of the subnet to use"
  type        = string
}

variable "node_service_account_email" {
  description = "Service account email for GKE node pool"
  type        = string
}

variable "gitops_repo_url" {
  description = "URL of the GitHub repository used for GitOps"
  type        = string
}

variable "gitops_revision" {
  description = "Git revision (branch/tag) for GitOps applications"
  type        = string
}
