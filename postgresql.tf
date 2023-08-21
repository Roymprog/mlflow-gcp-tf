resource "google_sql_database_instance" "postgres_pvp_mlflow" {
  name             = "${var.project_prefix}-mlflow-postgres-pvp"
  region           = var.location
  database_version = "POSTGRES_15"
  root_password    = "abcABC123!"
  settings {
    tier = "db-custom-2-7680"
    password_validation_policy {
      min_length                  = 6
      reuse_interval              = 2
      complexity                  = "COMPLEXITY_DEFAULT"
      disallow_username_substring = true
      password_change_interval    = "30s"
      enable_password_policy      = true
    }
    ip_configuration {
      ipv4_enabled    = "true"
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false

  depends_on    = [module.services]
}

resource "google_sql_database" "mlflow_database" {
  name     = "mlflow"
  instance = google_sql_database_instance.postgres_pvp_mlflow.name
  project = var.project_id

  depends_on = [google_sql_database_instance.postgres_pvp_mlflow]
}
