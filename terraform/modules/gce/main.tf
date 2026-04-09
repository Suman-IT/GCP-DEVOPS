// gce/main.tf - Google Compute Engine VM Instance

resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  tags = concat(["gce-instance", var.environment], var.additional_tags)

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network_ip = var.network_ip
    network    = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = var.enable_public_ip ? [1] : []
      content {
        nat_ip = var.static_public_ip != null ? var.static_public_ip : null
      }
    }
  }

  metadata = merge(
    {
      enable-oslogin           = "TRUE"
      block-project-ssh-keys   = "FALSE"
    },
    var.metadata
  )

  metadata_startup_script = var.startup_script

  service_account {
    email  = var.service_account_email
    scopes = var.scopes
  }

  labels = merge(
    {
      environment = var.environment
      managed-by  = "terraform"
    },
    var.labels
  )

  scheduling {
    preemptible         = var.preemptible
    automatic_restart   = !var.preemptible
    on_host_maintenance = var.preemptible ? "TERMINATE" : "MIGRATE"
  }

  deletion_protection       = var.deletion_protection
  allow_stopping_for_update = true

  depends_on = []
}

// Firewall rules for the VM
resource "google_compute_firewall" "vm_allow_ssh" {
  count   = var.enable_ssh ? 1 : 0
  name    = "${var.instance_name}-allow-ssh"
  network = var.network
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidr_blocks
  target_tags   = ["gce-instance"]
}

resource "google_compute_firewall" "vm_allow_custom" {
  for_each = var.additional_firewall_rules

  name    = "${var.instance_name}-${each.key}"
  network = var.network
  project = var.project_id

  allow {
    protocol = each.value.protocol
    ports    = each.value.ports
  }

  source_ranges = each.value.source_ranges
  target_tags   = ["gce-instance"]
}
