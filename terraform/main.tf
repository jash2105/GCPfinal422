provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "gallerybucketflask" {
  name     = "${var.project_id}-gallerybucketflask-bucket"
  location = var.region
  force_destroy = true
}

resource "google_compute_network" "custom_vpc" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom_subnet" {
  name          = "custom-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.custom_vpc.id
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow-https" {
  name    = "allow-https"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

resource "google_compute_firewall" "allow-flask-8080" {
  name    = "allow-flask-8080"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["flask-server"]
}
