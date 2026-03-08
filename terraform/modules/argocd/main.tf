// argocd/main.tf

resource "argocd_repository" "repo" {
  repo       = var.repo_url
  username   = var.repo_username
  password   = var.repo_password
  insecure   = var.repo_insecure
  depends_on = [var.argocd_namespace_ready]
}

resource "argocd_project" "project" {
  metadata {
    name      = var.project
    namespace = var.namespace
  }

  spec {
    source_repos = [var.repo_url]
    destination {
      name      = "*"
      namespace = "*"
    }
  }

  depends_on = [var.argocd_namespace_ready]
}

resource "argocd_application" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    project = var.project

    source {
      repo_url        = var.repo_url
      path            = var.path
      target_revision = var.target_revision

      helm {
        # optional list of values files stored in the Git repo under the path
        value_files = var.value_files
      }
    }

    destination {
      server    = var.destination_server
      namespace = var.destination_namespace
    }

    sync_policy {
      automated {
        prune      = var.automated_prune
        self_heal  = var.automated_self_heal
      }
    }
  }

  depends_on = [argocd_project.project]
}
