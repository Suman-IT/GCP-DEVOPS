// iam/variables.tf

variable "project_id" {
  description = "Project to create the service account in"
  type        = string
}

variable "account_id" {
  description = "ID for the new service account"
  type        = string
}

variable "display_name" {
  description = "Friendly name for SA"
  type        = string
  default     = "default-sa"
}

variable "roles" {
  description = "List of IAM roles to bind to the service account"
  type        = list(string)
  default     = []
}

variable "bind_k8s_sa" {
  description = "Whether to add workload identity binding for a Kubernetes service account"
  type        = bool
  default     = false
}

variable "k8s_project" {
  description = "GCP project containing the GKE cluster whose KSA will be bound"
  type        = string
  default     = ""
}

variable "k8s_namespace" {
  description = "Namespace of the k8s service account"
  type        = string
  default     = "default"
}

variable "k8s_sa" {
  description = "Name of the k8s service account"
  type        = string
  default     = ""
}
