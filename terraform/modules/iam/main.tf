// iam/main.tf

resource "google_service_account" "default" {
  account_id   = var.account_id
  project      = var.project_id
  display_name = var.display_name
}

# grant roles to a service account
resource "google_project_iam_member" "sa_roles" {
  for_each = toset(var.roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.default.email}"
}

# workload identity binding for a k8s service account
resource "google_service_account_iam_member" "workload_identity" {
  count  = var.bind_k8s_sa ? 1 : 0
  service_account_id = google_service_account.default.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.k8s_project}.svc.id.goog[${var.k8s_namespace}/${var.k8s_sa}]"
}
