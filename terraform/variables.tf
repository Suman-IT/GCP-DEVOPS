// terraform/variables.tf

variable "argocd_server_addr" {
  description = "Address of the ArgoCD API server"
  type        = string
  default     = ""
}

variable "argocd_auth_token" {
  description = "Bearer token used by the ArgoCD provider"
  type        = string
  default     = ""
  sensitive   = true
}

variable "org_id" {
  description = "Organization ID for new projects (optional for free tier accounts)"
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "Billing account to attach to projects (optional for free tier accounts)"
  type        = string
  default     = ""
}

variable "network_project_id" {
  description = "Identifier for Shared VPC host project"
  type        = string
}

variable "dev_project_id" {
  description = "Identifier for dev workload project"
  type        = string
}

variable "qa_project_id" {
  description = "Identifier for QA workload project"
  type        = string
}

variable "prod_project_id" {
  description = "Identifier for prod workload project"
  type        = string
}
