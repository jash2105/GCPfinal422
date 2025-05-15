output "sql_private_ip" {
  value = google_sql_database_instance.mysql_instance.private_ip_address
}
