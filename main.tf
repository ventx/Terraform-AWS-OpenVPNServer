provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



resource "aws_security_group" "vpnsecuritygroup" {
  name        = "Open VPN Security Group"
  description = "Allow http and https"
  vpc_id      = "${data.aws_vpc.selected.id}"

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

resource "aws_instance" "openvpnserver" {
  ami             = data.aws_ami.latest-ubuntu.id
  instance_type   = "${var.instancetype}"
  user_data       = "${data.template_file.userdata.rendered}"
  key_name        = "${var.keyname}"
  security_groups = ["${aws_security_group.vpnsecuritygroup.id}"]
  subnet_id       = "${var.subnetid}"

  tags = {
    Owner = "${var.owner}"
    Name  = "${var.instancename}"
  }
}

data "template_file" "userdata" {
  template = "${file("userdata.sh")}"

  vars = {
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

data "aws_vpc" "selected" {
  id = "${var.vpc}"
}

data "aws_route53_zone" "hostedzone" {
  name         = "${var.domain}"
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.hostedzone.id}"
  name    = "${var.subdomain}.${data.aws_route53_zone.hostedzone.name}"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.openvpnserver.public_ip}"]
}
