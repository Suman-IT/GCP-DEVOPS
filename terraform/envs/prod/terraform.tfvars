# ==============================================================================
# Prod Environment Configuration - Asia Region (Tokyo)
# ==============================================================================

environment                = "prod"
project_id                 = "your-prod-project-id"
region                     = "asia-northeast1"
org_id                     = ""
billing_account            = ""
artifact_repo_id           = "prod-app-repo"
cluster_name               = "prod-cluster"
network_self_link          = "projects/shared-vpc-host-project-492811/global/networks/shared-vpc"
subnet_self_link           = "projects/shared-vpc-host-project-492811/regions/asia-northeast1/subnetworks/subnet-prod"
node_service_account_email = "gke-node-sa@shared-vpc-host-project-492811.iam.gserviceaccount.com"
gitops_repo_url            = "https://github.com/Suman-IT/GCP-DEVOPS.git"
gitops_revision            = "main"
host_project_id            = "shared-vpc-host-project-492811"
service_project_number     = 399031706541
create_project             = false

# GCE Instance Configuration
instance_name     = "prod-app-vm"
machine_type      = "n1-standard-2"
zone              = "asia-northeast1-a"
boot_disk_image   = "debian-cloud/debian-12"
boot_disk_size_gb = 30
boot_disk_type    = "pd-ssd"
enable_public_ip  = false
preemptible       = false

vm_labels = {
  app   = "prod-app"
  owner = "devops"
  env   = "prod"
}

vm_metadata = {
  enable-oslogin = "TRUE"
}

startup_script = <<-EOT
  #!/bin/bash
  apt-get update
  apt-get install -y curl git wget
  echo "Prod VM initialization completed"
EOT
