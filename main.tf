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

resource "google_vpc_access_connector" "connector" {
  name          = "terraform-connector"
  region        = var.region
  project       = var.project_id
  ip_cidr_range = "10.9.0.0/28"
  network       = "default"
}

# Google Cloud Storage bucket for event triggers or function storage
resource "google_storage_bucket" "function_bucket" {
  name          = "${var.project_id}-function-bucket"
  location      = var.region
  force_destroy = true
}

module "function_hello_world" {
  source              = "./modules/cloud_function"
  name                = "function-hello-world"
  region              = var.region
  runtime             = "python311"
  entry_point         = "hello_world" # Defined in main.py
  source_directory    = "functions/hello-world"
  trigger_bucket      = google_storage_bucket.function_bucket.name
  vpc_connector_name  = google_vpc_access_connector.connector.name
  environment_vars    = var.environment_vars
}