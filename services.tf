module "services" {
  source = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.2"

  project_id = var.project_id

  disable_dependent_services	= true
  disable_services_on_destroy	= true

  activate_apis = [
    "storage-api.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
}
