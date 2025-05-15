terraform {
  backend "gcs" {
    bucket = "tf-state-eastern-hawk"
    prefix = "se422final"
  }
}
