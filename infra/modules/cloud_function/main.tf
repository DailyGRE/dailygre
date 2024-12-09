data "archive_file" "default" {
  type        = "zip"
  output_path = "/tmp/${var.name}.zip"
  source_dir  = var.source_directory
}

resource "google_storage_bucket_object" "function_source" {
  name   = "${var.name}.zip"
  bucket = var.source_bucket
  source = data.archive_file.default.output_path
}

resource "google_cloudfunctions2_function" "default" {
  name = var.name
  location = var.region
  
  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = var.source_bucket
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    vpc_connector = var.vpc_connector_name
  }
}

output "function_uri" {
  value = google_cloudfunctions2_function.default.service_config[0].uri
}
