// shared_vpc_attachment/variables.tf

variable "host_project_id" {
  description = "Shared VPC host project ID"
  type        = string
}

variable "service_project_id" {
  description = "Service project ID to attach to shared VPC"
  type        = string
}

variable "service_project_number" {
  description = "Service project number for IAM bindings"
  type        = number
}