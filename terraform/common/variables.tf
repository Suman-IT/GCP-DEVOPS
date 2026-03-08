// common/variables.tf

variable "network_project_id" {
  description = "Shared VPC host project ID"
  type        = string
}

variable "region" {
  description = "Region for resources"
  type        = string
  default     = "us-central1"
}


variable "network_name" {
  description = "Name of VPC to create"
  type        = string
  default     = "shared-vpc"
}

variable "subnets" {
  description = "Subnet definitions for network module"
  type        = list(object({
    name   = string
    cidr   = string
    region = string
  }))
  default = [
    {
      name   = "subnet-01"
      cidr   = "10.0.0.0/24"
      region = "us-central1"
    }
  ]
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = ""
}