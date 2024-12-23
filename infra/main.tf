terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "< 7"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_secret_manager_secret_version" "github_pat" {
  project = var.project_id
  secret  = "github-pat"
  version = "latest"
}

module "im_workspace" {
  source  = "terraform-google-modules/bootstrap/google//modules/im_cloudbuild_workspace"
  version = "~> 10.0"

  project_id    = var.project_id
  deployment_id = "${var.project_id}-im-deployment"

  tf_repo_type           = "GITHUB"
  im_deployment_repo_uri = var.im_deployment_repo_uri
  im_deployment_ref      = "main"
  im_deployment_repo_dir = "infra"
  im_tf_variables = join(",", [
    "project_id=${var.project_id}",
    "region=${var.region}",
    "im_deployment_repo_uri=${var.im_deployment_repo_uri}",
    "im_deployment_ref=${var.im_deployment_ref}",
    "github_app_installation_id=${var.github_app_installation_id}",
  ])
  infra_manager_sa_roles = [
    "roles/cloudbuild.connectionViewer",
    "roles/cloudbuild.builds.editor",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountUser",
    "roles/secretmanager.viewer",
    "roles/secretmanager.secretAccessor",
    "roles/storage.admin",
    "roles/vpcaccess.admin",
    "roles/cloudfunctions.developer"
  ]
  tf_version = "1.5.7"

  github_app_installation_id   = var.github_app_installation_id
  github_personal_access_token = data.google_secret_manager_secret_version.github_pat.secret_data
}

resource "google_storage_bucket" "function_bucket" {
  name          = "${var.project_id}-function-sources"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket" "content_bucket" {
  name                        = "${var.project_id}-content-bucket"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}


resource "google_vpc_access_connector" "connector" {
  name          = "terraform-connector"
  region        = var.region
  project       = var.project_id
  ip_cidr_range = "10.9.0.0/28"
  network       = "default"
  min_instances = 2
  max_instances = 3
}

module "functions" {
  source   = "./modules/cloud_function"
  for_each = local.cloud_functions
  # Configurations per function
  name               = each.key
  region             = var.region
  runtime            = "python311"
  entry_point        = replace(each.key, "-", "_") # Assuming the entry point is named after the function, replacing dashes with underscores
  source_directory   = "../functions/${each.key}"
  source_bucket      = google_storage_bucket.function_bucket.name
  vpc_connector_name = google_vpc_access_connector.connector.name
  function_config    = each.value
  environment_variables = {
    GCS_BUCKET_NAME = google_storage_bucket.content_bucket.name
  }
}
