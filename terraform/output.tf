output "dejima-manager" {
  value = "${google_compute_instance.dejima_manager.network_interface.0.access_config.0.nat_ip}"
}