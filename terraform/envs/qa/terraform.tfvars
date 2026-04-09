# ==============================================================================
# QA Environment Configuration - Asia Region (Delhi)
# ==============================================================================

environment                = "qa"
project_id                 = "your-qa-project-id"
region                     = "asia-south1"
org_id                     = ""
billing_account            = ""
artifact_repo_id           = "qa-app-repo"
cluster_name               = "qa-cluster"
network_self_link          = "projects/shared-vpc-host-project-492811/global/networks/shared-vpc"
subnet_self_link           = "projects/shared-vpc-host-project-492811/regions/asia-south1/subnetworks/subnet-qa"
node_service_account_email = "gke-node-sa@shared-vpc-host-project-492811.iam.gserviceaccount.com"
gitops_repo_url            = "https://github.com/Suman-IT/GCP-DEVOPS.git"
gitops_revision            = "main"
host_project_id            = "shared-vpc-host-project-492811"
service_project_number     = 399031706541
create_project             = false

# GCE Instance Configuration
instance_name     = "qa-app-vm"
machine_type      = "e2-medium"
zone              = "asia-south1-a"
boot_disk_image   = "debian-cloud/debian-12"
boot_disk_size_gb = 20
boot_disk_type    = "pd-standard"
enable_public_ip  = true
preemptible       = false

vm_labels = {
  app   = "qa-app"
  owner = "devops"
  env   = "qa"
}

vm_metadata = {
  enable-oslogin = "TRUE"
}

startup_script = "#!/bin/bash\napt-get update\napt-get install -y curl git wget\necho 'QA VM initialization completed'"
