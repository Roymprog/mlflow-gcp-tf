locals {
  name = "mlflow-srv"
}

resource "google_cloud_run_v2_service" "mlflow_cloud_run" {
  name     = local.name
  location = var.location
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.postgres_pvp_mlflow.connection_name]
      }
    }
    containers {
      image = "${var.location}-docker.pkg.dev/${var.project_id}/docker/mlflow:2.5.0"
      env {
            name = "DB_USER"
            value = "postgres"
      }
      env {
            name = "DB_PASSWORD"
            value = google_sql_database_instance.postgres_pvp_mlflow.root_password
      }
      env {
            name = "DB_NAME"
            value = "mlflow"
      }
      env {
            name = "BACKEND_STORE_URI"
            value = "postgresql+psycopg2://postgres:${google_sql_database_instance.postgres_pvp_mlflow.root_password}@/mlflow?host=/cloudsql/${google_sql_database_instance.postgres_pvp_mlflow.connection_name}"
      }
      env {
            name = "DEFAULT_ARTIFACT_ROOT"
            value = "gs://rvs-mlflow-artifacts"
      }
      env {
            name = "INSTANCE_UNIX_SOCKET"
            value = "/cloudsql/${google_sql_database_instance.postgres_pvp_mlflow.connection_name}"
      }
      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = google_sql_database_instance.postgres_pvp_mlflow.connection_name
      }
      resources {
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
      }
      startup_probe {
        initial_delay_seconds = 0
        timeout_seconds = 240
        period_seconds = 240
        failure_threshold = 1
        tcp_socket {
          port = 8080
        }
      }
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
    scaling {
        min_instance_count = 0
        max_instance_count = 1
    }
    service_account = google_service_account.mlflow_service_account.email
  }

  traffic {
    type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }


  depends_on = [google_service_account.mlflow_service_account, module.services]
}

resource "google_service_account" "mlflow_service_account" {
  account_id   = "mlflow-tf-sa"
  display_name = "Service Account for MLFlow service."
}

resource "google_project_iam_member" "mlflow_sa_roles" {
    for_each = toset([
        "roles/cloudsql.client",
        "roles/secretmanager.secretAccessor",
        "roles/storage.objectViewer",
    ])
    project = var.project_id
    role = each.value
    member = "serviceAccount:${google_service_account.mlflow_service_account.email}"
}
