data "template_file" "dejima-manager-init" {
  template = "${file("dejima-manager-init.sh")}"
}
