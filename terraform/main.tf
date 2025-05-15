resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "google-managed-services-${var.region}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
  address       = "10.10.0.0"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https-gcpfinal422"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-gcpfinal422"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_app_8080" {
  name    = "allow-app-8080-gcpfinal422"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_sql_database_instance" "mysql_instance" {
  name             = "gallery-sql"
  database_version = "MYSQL_5_7"
  region           = var.region

  settings {
    tier = "db-n1-standard-1"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.id
    }
  }

  deletion_protection = false
  depends_on          = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_user" "users" {
  name     = var.db_user
  instance = google_sql_database_instance.mysql_instance.name
  password = var.db_password
}

resource "google_sql_database" "gallery_db" {
  name     = var.db_name
  instance = google_sql_database_instance.mysql_instance.name
}
