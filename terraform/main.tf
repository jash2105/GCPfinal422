provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "example" {
  name     = "${var.project_id}-example-bucket"
  location = var.region
  force_destroy = true
}
