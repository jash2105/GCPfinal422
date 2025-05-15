resource "google_compute_instance" "flask_vm" {
  name         = "flask-vm"
  machine_type = "e2-standard-2"
  zone         = var.zone

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name
    access_config {}
  }

  metadata_startup_script = file("cloud-init.sh")

  service_account {
    email  = "default"
    scopes = ["cloud-platform"]
  }

  tags = ["http-server", "https-server"]
}
