// common/outputs.tf

output "network_self_link" {
  description = "Self link of the shared VPC network"
  value       = module.network.network_self_link
}

output "network_name" {
  description = "Name of the shared VPC network"
  value       = var.network_name
}

output "subnet_self_links" {
  description = "Self links of the subnets"
  value       = module.network.subnet_self_links
}

output "subnets" {
  description = "Subnet details including name, CIDR, region"
  value       = var.subnets
}

output "node_service_account_email" {
  description = "Email of the GKE node service account"
  value       = module.gke_node_sa.service_account_email
}

output "host_project_id" {
  description = "The shared VPC host project ID"
  value       = var.network_project_id
}