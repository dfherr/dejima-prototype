provider "google" {
  credentials = "$(file("wise-vault-250911-credentials.json"))"
  project = "wise-vault-250911"
}