terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.location
}

provider "google-beta" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.location
}

resource "google_artifact_registry_repository" "docker-image-registry" {
  location      = var.location
  repository_id = "${var.project_prefix}-image-registry"
  description   = "MLFlow Docker image repository"
  format        = "DOCKER"
  depends_on    = [module.services]
}
