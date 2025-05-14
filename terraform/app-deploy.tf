provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "flask_app" {
  name     = "FinalExam"
  location = var.region

  template {
    spec {
      containers {
        image = var.image_url

        env {
          name  = "DB_USER"
          value = "se422"
        }

        env {
          name  = "DB_PASSWORD"
          value = "-:L(((\\ztye&(Vrv"
        }

        env {
          name  = "DB_NAME"
          value = "finalprojectdb"
        }

        env {
          name  = "DB_CONNECTION_NAME"
          value = "steady-copilot-459615-f4:us-central1:finalprojectdb"
        }

        ports {
          container_port = 8080
        }
      }
    }
  }

  traffics {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_member" "allow_all" {
  location = google_cloud_run_service.flask_app.location
  project  = var.project_id
  service  = google_cloud_run_service.flask_app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_sql_database_instance" "default" {
  name             = "photo-app-db"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      private_network = var.vpc_network
    }
  }
}

resource "google_sql_database" "app_db" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "app_user" {
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  password = var.db_password
}
