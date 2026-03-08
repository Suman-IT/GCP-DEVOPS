// gke/outputs.tf

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}

output "kubernetes_api_server" {
  description = "Kubernetes API server address for ArgoCD"
  value       = "https://${google_container_cluster.primary.endpoint}"
}
