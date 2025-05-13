terraform {
  backend "gcs" {
    bucket  = "gallerybucket1"
    prefix  = "terraform/state"
  }
}