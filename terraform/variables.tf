variable "image_manager" {
  default = "wise-vault-250911/dejima-prototype-1567116541"
}

variable "manager_instance_type" {
  default = "n1-standard-4"
}

variable "image_peer" {
  default = "wise-vault-250911/dejima-prototype-1567116541"
}

variable "peer_instance_type" {
  default = "n1-standard-1"
}

variable "peer_zone1" {
  default = "us-central1-a"
}
variable "peer_zone2" {
  default = "us-east4-a"
}
variable "peer_zone3" {
  default = "us-west1-a"
}

variable "peer_zone4" {
  default = "europe-west3-a"
}

variable "peer_zone5" {
  default = "europe-west2-a"
}