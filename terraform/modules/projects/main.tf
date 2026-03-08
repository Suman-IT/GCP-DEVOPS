// projects/main.tf

resource "google_project" "this" {
  name       = var.name
  project_id = var.project_id
  org_id     = var.org_id != "" ? var.org_id : null
  billing_account = var.billing_account != "" ? var.billing_account : null
}

resource "google_project_service" "enabled" {
  for_each = var.services
  project  = google_project.this.project_id
  service  = each.key
}
