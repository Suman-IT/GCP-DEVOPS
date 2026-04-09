// envs/variables.tf

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "project_id" {
  description = "GCP project ID for the environment"
  type        = string
}

variable "region" {
  description = "Region for resources"
  type        = string
}

variable "org_id" {
  description = "Organization ID under which project will be created (optional for free tier accounts)"
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "Billing account ID to attach to the project (optional for free tier accounts)"
  type        = string
  default     = ""
}

variable "create_project" {
  description = "Whether to create a new project (set to false if using existing project with free tier)"
  type        = bool
  default     = true
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

variable "host_project_id" {
  description = "Shared VPC host project ID"
  type        = string
}

variable "enable_shared_vpc_attachment" {
  description = "Whether Terraform should attach the environment project to the shared VPC host project"
  type        = bool
  default     = true
}

variable "service_project_number" {
  description = "Service project number for shared VPC attachment"
  type        = number
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

// GCE Instance Variables
variable "instance_name" {
  description = "GCE instance name"
  type        = string
}

variable "machine_type" {
  description = "Machine type for GCE instance"
  type        = string
}

variable "zone" {
  description = "Zone for GCE instance"
  type        = string
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
}

variable "enable_public_ip" {
  description = "Enable public IP for GCE instance"
  type        = bool
}

variable "preemptible" {
  description = "Use preemptible VM"
  type        = bool
}

variable "vm_labels" {
  description = "Labels for VM"
  type        = map(string)
}

variable "vm_metadata" {
  description = "Metadata for VM"
  type        = map(string)
}

variable "startup_script" {
  description = "Startup script for VM"
  type        = string
}
