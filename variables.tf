variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region to deploy resources"
  default     = "us-central1"
}

variable "environment_vars" {
  type        = map(string)
  description = "Environment variables for Cloud Functions"
  default     = {}
}
