// projects/variables.tf

variable "name" {
  description = "Friendly name of the project"
  type        = string
}

variable "project_id" {
  description = "Unique GCP project identifier"
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

variable "services" {
  description = "Map of service APIs to enable (keyed by service name)"
  type        = map(bool)
  default     = {}
}
