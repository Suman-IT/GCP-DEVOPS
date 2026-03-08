// argocd/variables.tf

variable "namespace" {
  description = "Namespace where ArgoCD lives (usually argocd)"
  type        = string
  default     = "argocd"
}

variable "project" {
  description = "ArgoCD project to assign the application to"
  type        = string
  default     = "default"
}

variable "repo_url" {
  description = "Git repository URL containing manifests/helm chart"
  type        = string
}

variable "repo_username" {
  description = "Username for Git repository authentication (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "repo_password" {
  description = "Password or token for Git repository authentication (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "repo_insecure" {
  description = "Allow insecure server connections for the repository"
  type        = bool
  default     = false
}

variable "argocd_namespace_ready" {
  description = "Dependency to ensure ArgoCD namespace is ready before deploying"
  type        = any
  default     = null
}

variable "name" {
  description = "Name of the ArgoCD Application"
  type        = string
}

variable "path" {
  description = "Path within the repository for this environment"
  type        = string
}

variable "target_revision" {
  description = "Git revision, branch or tag"
  type        = string
  default     = "HEAD"
}

variable "destination_server" {
  description = "Kubernetes API server address (eg https://kubernetes.default.svc)"
  type        = string
  default     = "https://kubernetes.default.svc"
}

variable "destination_namespace" {
  description = "Namespace in the cluster where resources will be created"
  type        = string
  default     = "default"
}

variable "value_files" {
  description = "Helm values files to use (relative to path). Example: [\"values-qa.yaml\"]"
  type        = list(string)
  default     = []
}

variable "automated_prune" {
  description = "Automatically prune resources when they are no longer in Git"
  type        = bool
  default     = true
}

variable "automated_self_heal" {
  description = "Automatically sync resources when they diverge from Git"
  type        = bool
  default     = true
}
  default     = []
}

variable "automated_prune" {
  description = "Enable automated pruning"
  type        = bool
  default     = true
}

variable "automated_self_heal" {
  description = "Enable automated self-healing"
  type        = bool
  default     = true
}
