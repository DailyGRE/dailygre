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
  type = string
  description = "Path to the function's source code directory"
}

variable "source_bucket" {
  type        = string
  description = "The Cloud Storage bucket where the function source code is stored"
}

variable "vpc_connector_name" {
  type        = string
  description = "The VPC Connector to use for the function's outbound traffic"
}

variable "region" {
  type        = string
  default     = "us-central1"
}
