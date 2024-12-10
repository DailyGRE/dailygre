variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region to deploy resources"
  default     = "us-central1"
}

variable "im_deployment_repo_uri" {
  type        = string
  description = "The URI of the Git repository containing the IM deployment"
}

variable "im_deployment_ref" {
  type        = string
  description = "The Git ref (branch or tag) of the IM deployment"
}

variable "github_app_installation_id" {
  type        = number
  description = "The Cloud Build GitHub App installation ID"
}
