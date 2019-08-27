data "template_file" "dejima-manager-init" {
  template = "${file("dejima-manager-init.sh")}"
}

data "template_file" "dejima-peer-init" {
  template = "${file("dejima-peer-init.sh")}"
  vars = {
    crane_file =  "${file("crane.yml")}"
    // to wait until manager is up and running
    manager_ip = "${google_compute_instance.dejima_manager.network_interface.0.access_config.0.nat_ip}"
  }
}
