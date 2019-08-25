resource "google_compute_firewall" "dejima_firewall" {
  name    = "dejima-firewall"
  network = "${google_compute_network.dejima_network.name}"
  direction     = "INGRESS"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "2377", "7946"]
  }

  allow {
    protocol = "udp"
    ports    = ["7946", "4789"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "dejima_firewall_internal" {
  name    = "dejima-firewall-internal"
  network = "${google_compute_network.dejima_network.name}"
  direction     = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.128.0.0/9"]
}

resource "google_compute_network" "dejima_network" {
  name = "dejima-network"
}
