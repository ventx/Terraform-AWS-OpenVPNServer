provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

data "aws_vpc" "target" {
  id = "${var.vpc}"
}

data "aws_route53_zone" "target" {
  name         = "${var.domain}"
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.target.zone_id}"
  name    = "${var.subdomain}.${data.aws_route53_zone.target.name}"
  type    = "A"
  ttl     = "30"
  records = ["${module.openvpninstance.publicip}"]
}

resource "aws_security_group" "vpnsecuritygroup" {
  name        = "Open VPN Security Group"
  description = "Allow http and https"
  vpc_id      = "${data.aws_vpc.target.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "openvpninstance" {
  ami          = "${var.ami}"
  instancetype = "${var.instancetype}"
  source       = "./instance"
  instancename = "${var.instancename}"
  sg           = "${aws_security_group.vpnsecuritygroup.id}"
  key_country  = "${var.key_country}"
  key_province = "${var.key_province}"
  key_city     = "${var.key_city}"
  key_org      = "${var.key_org}"
  key_email    = "${var.key_email}"
  key_ou       = "${var.key_ou}"
  passwd       = "${var.passwd}"
  domain       = "${var.domain}"
  sslmail      = "${var.sslmail}"
  owner        = "${var.owner}"
  subdomain    = "${var.subdomain}"
  subnetid     = "${var.subnetid}"
  keyname      = "${var.keyname}"
  adminurl     = "${var.domain}"


}
