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

resource "google_storage_bucket" "function_bucket" {
  name          = "${var.project_id}-function-sources"
  location      = var.region
  force_destroy = true
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
