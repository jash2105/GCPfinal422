output "app_endpoint" {
  description = "34.134.128.223"
  value       = google_compute_instance.flask_vm.network_interface[0].access_config[0].nat_ip
}

output "database_connection_name" {
  description = "finalprojectdb"
  value       = google_sql_database_instance.main.connection_name
}

output "database_instance_ip" {
  description = "34.173.250.12"
  value       = google_sql_database_instance.main.public_ip_address
}
