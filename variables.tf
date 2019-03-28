variable "ami" {
  description = "AMI to be used, default is Ubuntu 18.67 Bionic"
  default     = "ami-090f10efc254eaf55"
}

variable "region" {
  description = "AWS Region"
}

variable "vpc" {
  description = "AWS VPC"
}

variable "profile" {
  description = "AWS Profile"
}

variable "instancetype" {
  description = "EC2 instance type"
}

variable "instancename" {
  description = "EC2 instance name"
}

variable "keyname" {
  description = "SSH key name"
}

variable "key_country" {
  description = "key_country"
}

variable "key_province" {
  description = "key_province"
}

variable "key_city" {
  description = "key_city"
}

variable "key_org" {
  description = "key_org"
}

variable "key_email" {
  description = "key_email"
}

variable "key_ou" {
  description = "key_ou"
}

variable "passwd" {
  description = "OpenVPN admin password"
}

variable "domain" {
  description = "OpenVPN server TLD"
}

variable "sslmail" {
  description = "E-Mail for LetsEncrypt"
}

variable "owner" {
  description = "Owner Tag for AWS console"
}

variable "subdomain" {
  description = "Subdomain"
}

variable "subnetid" {
  description = "Subnet for the VPN Instance"
}

variable "adminurl" {
  description = "OpenVPN Admin login"
}
