// gke/variables.tf

variable "project_id" {
  description = "Target project for the cluster"
  type        = string
}

variable "region" {
  description = "Region where the cluster will be created"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "gke-cluster"
}

variable "network" {
  description = "VPC network self link or name"
  type        = string
}

variable "subnetwork" {
  description = "Subnet self link or name"
  type        = string
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "Number of nodes in the default pool"
  type        = number
  default     = 1
}

variable "node_service_account" {
  description = "Service account used by the node pool"
  type        = string
}
