// network/outputs.tf

output "network_self_link" {
  value = google_compute_network.vpc.self_link
}

output "subnet_self_links" {
  value = google_compute_subnetwork.subnet[*].self_link
}
