variable "name" {
  type        = string
  description = "The name of the Cloud Function"
}

variable "runtime" {
  type        = string
  description = "The runtime environment for the function"
  default     = "python311"
}

variable "entry_point" {
  type        = string
  description = "The entry point for the function"
}

variable "source_directory" {
  type        = string
  description = "Path to the function's source code"
}

variable "trigger_bucket" {
  type        = string
  description = "The Cloud Storage bucket to trigger the function"
}

variable "vpc_connector_name" {
  type        = string
  description = "The VPC Connector to use for the function's outbound traffic"
}

variable "environment_vars" {
  type        = map(string)
  description = "Environment variables for the function"
  default     = {}
}

variable "region" {
  type        = string
  default     = "us-central1"
}