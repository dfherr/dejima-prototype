resource "google_compute_instance" "dejima_manager" {
  name         = "dejima-manager"
  machine_type = "${var.manager_instance_type}"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "${var.image_manager}"
    }
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

  metadata_startup_script = "${data.template_file.dejima-manager-init.rendered}"
}
