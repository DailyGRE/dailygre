terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_secret_manager_secret_version" "github_pat" {
  project = var.project_id
  secret = "github-pat"
  version = "latest"
}

module "im-workspace" {
 source = "terraform-google-modules/bootstrap/google//modules/im_cloudbuild_workspace"
 version = "~> 7.0"

 project_id = var.project_id
 deployment_id = "${var.project_id}-im-deployment"
 im_deployment_repo_uri = var.im_deployment_repo_uri
 im_deployment_ref = var.im_deployment_ref

 github_app_installation_id = var.github_app_installation_id
 github_personal_access_token = data.google_secret_manager_secret_version.github_pat.secret_data
}

resource "google_storage_bucket" "function_bucket" {
  name          = "${var.project_id}-function-sources"
  location      = var.region
  force_destroy = true
}

resource "google_vpc_access_connector" "connector" {
  name          = "terraform-connector"
  region        = var.region
  project       = var.project_id
  ip_cidr_range = "10.9.0.0/28"
  network       = "default"
}

module "functions" {
  source              = "./modules/cloud_function"
  for_each            = var.function_names
  # Configurations per function
  name                = each.key
  region              = var.region
  runtime             = "python311"
  entry_point         = replace(each.key, "-", "_")  # Assuming the entry point is named after the function, replacing dashes with underscores
  source_directory    = "../functions/${each.key}"
  source_bucket       = google_storage_bucket.function_bucket.name
  vpc_connector_name  = google_vpc_access_connector.connector.name
}
