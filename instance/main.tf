// OpenVPNServer
resource "aws_instance" "openvpnserver" {
  ami             = "${var.ami}"
  instance_type   = "${var.instancetype}"
  user_data       = "${data.template_file.userdata.rendered}"
  key_name        = "${var.keyname}"
  security_groups = ["${var.sg}"]
  subnet_id       = "${var.subnetid}"

  tags = {
    Owner = "${var.owner}"
    Name  = "${var.instancename}"
  }
}

data "template_file" "userdata" {
  template = "${file("instance/userdata.sh")}"

  vars {
    key_country  = "${var.key_country}"
    key_province = "${var.key_province}"
    key_city     = "${var.key_city}"
    key_org      = "${var.key_org}"
    key_email    = "${var.key_email}"
    key_ou       = "${var.key_ou}"
    passwd       = "${var.passwd}"
    domain       = "${var.domain}"
    sslmail      = "${var.sslmail}"
    subdomain    = "${var.subdomain}"
    instancetype = "${var.instancetype}"
    keyname      = "${var.keyname}"
    adminurl     = "${var.domain}"
  }
}
