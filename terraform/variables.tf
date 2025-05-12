variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  default     = "us-central1"
}

variable "network_name" {
  description = "VPC network name"
  default     = "gallery-network"
}
