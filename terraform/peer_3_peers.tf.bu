resource "google_compute_instance_template" "dejima_peer_template" {
  name_prefix  = "dejima-peer-template-"
  machine_type = "${var.peer_instance_type}"

  // boot disk
  disk {
    source_image = "${var.image_peer}"
    boot        = true
    auto_delete = true
  }

  network_interface {
    network = "${google_compute_network.dejima_network.name}"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email = "terraformuser@wise-vault-250911.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = "${data.template_file.dejima-peer-init.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_from_template" "dejima_peer_bank" {
  name = "dejima-peer-bank"
  zone               = "${var.peer_zone1}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_gov" {
  name = "dejima-peer-gov"
  zone               = "${var.peer_zone2}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_insurance" {
  name = "dejima-peer-insurance"
  zone               = "${var.peer_zone3}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}