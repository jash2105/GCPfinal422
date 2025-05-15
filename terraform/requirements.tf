terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }

  required_version = ">= 1.0"
}

provider "google" {
  project = "eastern-hawk-459900-m6"
  region  = var.region
  zone    = var.zone
}
