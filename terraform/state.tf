terraform {
  backend "gcs" {
    credentials = "wise-vault-250911-credentials.json"
    bucket = "dejima-prototype"
    prefix = "terraform/state"
  }
}