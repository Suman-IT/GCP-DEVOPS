// gce/variables.tf

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "instance_name" {
  description = "Name of the VM instance"
  type        = string
  validation {
    condition     = can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.instance_name))
    error_message = "Instance name must start with lowercase letter, contain only lowercase letters, numbers, and hyphens."
  }
}

variable "machine_type" {
  description = "Machine type for the VM (e.g., n1-standard-1, e2-medium)"
  type        = string
  default     = "e2-medium"
}

variable "zone" {
  description = "Zone where the VM will be created"
  type        = string
}

variable "boot_disk_image" {
  description = "Boot disk image (e.g., ubuntu-os-cloud/ubuntu-2204-lts, debian-cloud/debian-11)"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "boot_disk_type" {
  description = "Boot disk type (e.g., pd-standard, pd-balanced, pd-ssd)"
  type        = string
  default     = "pd-standard"
}

variable "network" {
  description = "VPC network name or self_link"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name or self_link"
  type        = string
}

variable "network_ip" {
  description = "Private IP address for the instance"
  type        = string
  default     = null
}

variable "enable_public_ip" {
  description = "Whether to attach a public IP address"
  type        = bool
  default     = true
}

variable "static_public_ip" {
  description = "Static public IP address (optional)"
  type        = string
  default     = null
}

variable "service_account_email" {
  description = "Service account email for the VM"
  type        = string
  default     = null
}

variable "scopes" {
  description = "List of scopes to attach to the service account"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "metadata" {
  description = "Additional metadata key-value pairs"
  type        = map(string)
  default     = {}
}

variable "startup_script" {
  description = "Startup script to run on VM initialization"
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to apply to the instance"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional network tags"
  type        = list(string)
  default     = []
}

variable "preemptible" {
  description = "Whether the VM should be preemptible"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "enable_ssh" {
  description = "Enable SSH access via firewall rule"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "additional_firewall_rules" {
  description = "Additional firewall rules for the VM"
  type = map(object({
    protocol      = string
    ports         = list(string)
    source_ranges = list(string)
  }))
  default = {}
}
