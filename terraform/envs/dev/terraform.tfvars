# ==============================================================================
# Dev Environment Configuration - Asia Region (Singapore)
# ==============================================================================

environment                 = "dev"
project_id                  = "dev-project-492813"
region                      = "asia-southeast1"
org_id                      = ""
billing_account             = ""
artifact_repo_id            = "dev-app-repo"
cluster_name                = "dev-cluster"
network_self_link           = "projects/shared-vpc-host-project-492811/global/networks/shared-vpc"
subnet_self_link            = "projects/shared-vpc-host-project-492811/regions/asia-southeast1/subnetworks/subnet-dev"
node_service_account_email  = "gke-node-sa@shared-vpc-host-project-492811.iam.gserviceaccount.com"
gitops_repo_url             = "https://github.com/Suman-IT/GCP-DEVOPS.git"
gitops_revision             = "main"
host_project_id             = "shared-vpc-host-project-492811"
service_project_number      = 657523974370
create_project              = false

# GCE Instance Configuration
instance_name        = "dev-app-vm"
machine_type         = "e2-medium"
zone                 = "asia-southeast1-a"
boot_disk_image      = "debian-cloud/debian-12"
boot_disk_size_gb    = 20
boot_disk_type       = "pd-standard"
enable_public_ip     = true
preemptible          = false

vm_labels = {
  app   = "dev-app"
  owner = "devops"
  env   = "dev"
}

vm_metadata = {
  enable-oslogin = "TRUE"
}

startup_script = <<-EOT
#!/bin/bash
apt-get update
apt-get install -y curl git wget
echo "Dev VM initialization completed"
EOT