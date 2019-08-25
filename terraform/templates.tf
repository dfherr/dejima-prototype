data "template_file" "dejima-manager-init" {
  template = "${file("dejima-manager-init.sh")}"
}

data "template_file" "dejima-peer-init" {
  template = "${file("dejima-peer-init.sh")}"
}
