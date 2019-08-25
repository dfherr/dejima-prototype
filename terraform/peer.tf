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

  // scheduling {
  //   preemptible = true
  //   automatic_restart = false
  // }

  metadata_startup_script = "${data.template_file.dejima-peer-init.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "dejima_peers1" {
  provider = "google-beta"
  name = "dejima-peers1"

  base_instance_name = "dejima-peer1"
  zone               = "${var.peer_zone1}"

  target_size  = 1

  update_policy {
    type = "PROACTIVE"
    minimal_action = "REPLACE"
    max_unavailable_percent = 100
    max_surge_percent = 100
    min_ready_sec = 0
  }

  version {
    name = "dejima-peer"
    instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
  }
}
resource "google_compute_instance_group_manager" "dejima_peers2" {
  provider = "google-beta"
  name = "dejima-peers2"

  base_instance_name = "dejima-peer2"
  zone               = "${var.peer_zone2}"

  target_size  = 1

  update_policy {
    type = "PROACTIVE"
    minimal_action = "REPLACE"
    max_unavailable_percent = 100
    max_surge_percent = 100
    min_ready_sec = 0
  }

  version {
    name = "dejima-peer"
    instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
  }
}

resource "google_compute_instance_group_manager" "dejima_peers3" {
  provider = "google-beta"
  name = "dejima-peers3"

  base_instance_name = "dejima-peer3"
  zone               = "${var.peer_zone3}"

  target_size  = 1

  update_policy {
    type = "PROACTIVE"
    minimal_action = "REPLACE"
    max_unavailable_percent = 100
    max_surge_percent = 100
    min_ready_sec = 0
  }

  version {
    name = "dejima-peer"
    instance_template = "${google_compute_instance_template.dejima_peer_template.self_link}"
  }
}
