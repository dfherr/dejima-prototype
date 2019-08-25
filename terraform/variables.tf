variable "image_manager" {
  default = "wise-vault-250911/dejima-prototype-1566736944"
}

variable "manager_instance_type" {
  default = "n1-standard-2"
}

variable "image_peer" {
  default = "wise-vault-250911/dejima-prototype-1566736944"
}

variable "peer_instance_type" {
  default = "n1-standard-2"
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