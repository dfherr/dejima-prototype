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

resource "google_compute_instance_from_template" "dejima_peer_bank2" {
  name = "dejima-peer-bank2"
  zone               = "${var.peer_zone1}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_bank3" {
  name = "dejima-peer-bank3"
  zone               = "${var.peer_zone2}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_bank4" {
  name = "dejima-peer-bank4"
  zone               = "${var.peer_zone2}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_bank5" {
  name = "dejima-peer-bank5"
  zone               = "${var.peer_zone3}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_bank6" {
  name = "dejima-peer-bank6"
  zone               = "${var.peer_zone3}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_bank7" {
  name = "dejima-peer-bank7"
  zone               = "${var.peer_zone4}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_bank8" {
  name = "dejima-peer-bank8"
  zone               = "${var.peer_zone5}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_gov" {
  name = "dejima-peer-gov"
  zone               = "${var.peer_zone1}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_gov2" {
  name = "dejima-peer-gov2"
  zone               = "${var.peer_zone2}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}
resource "google_compute_instance_from_template" "dejima_peer_gov3" {
  name = "dejima-peer-gov3"
  zone               = "${var.peer_zone3}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}
resource "google_compute_instance_from_template" "dejima_peer_gov4" {
  name = "dejima-peer-gov4"
  zone               = "${var.peer_zone4}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}
resource "google_compute_instance_from_template" "dejima_peer_gov5" {
  name = "dejima-peer-gov5"
  zone               = "${var.peer_zone5}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}
resource "google_compute_instance_from_template" "dejima_peer_insurance" {
  name = "dejima-peer-insurance"
  zone               = "${var.peer_zone2}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}

resource "google_compute_instance_from_template" "dejima_peer_insurance2" {
  name = "dejima-peer-insurance2"
  zone               = "${var.peer_zone3}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}
resource "google_compute_instance_from_template" "dejima_peer_insurance3" {
  name = "dejima-peer-insurance3"
  zone               = "${var.peer_zone3}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}
resource "google_compute_instance_from_template" "dejima_peer_insurance4" {
  name = "dejima-peer-insurance4"
  zone               = "${var.peer_zone3}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}
resource "google_compute_instance_from_template" "dejima_peer_insurance5" {
  name = "dejima-peer-insurance5"
  zone               = "${var.peer_zone4}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}
resource "google_compute_instance_from_template" "dejima_peer_insurance6" {
  name = "dejima-peer-insurance6"
  zone               = "${var.peer_zone4}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}
resource "google_compute_instance_from_template" "dejima_peer_insurance7" {
  name = "dejima-peer-insurance7"
  zone               = "${var.peer_zone5}"

  source_instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
}