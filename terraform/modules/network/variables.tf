// network/variables.tf

variable "project_id" {
  description = "GCP project where network will be created"
  type        = string
}

variable "name" {
  description = "VPC network name"
  type        = string
  default     = "shared-vpc"
}

variable "subnets" {
  description = "List of subnet definitions (name, cidr, region)"
  type = list(object({
    name   = string
    cidr   = string
    region = string
  }))
  default = []
}

variable "enable_shared_vpc_host" {
  description = "Enable this project as a shared VPC host"
  type        = bool
  default     = false
}
