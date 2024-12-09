variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region to deploy resources"
  default     = "us-central1"
}

variable "function_names" {
  description = "A map of function names to their configurations"
  type = map(any)
  default = {
    "hello-world" = {}
    }
}
