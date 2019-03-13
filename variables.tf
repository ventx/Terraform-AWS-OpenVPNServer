variable "region" {
  description = "Region to use"
}
variable "subdomain" {
  description = "Subdomain"
}
variable "ami" {
  description = "AWS AMI to use"
}
variable "instancetype" {
  description = "AWS Instance Type"
}
variable "instancename" {
  description = "Name of the Instance"
}
variable "key_country" {
  description = "OpenVPN CA Country Name"
}
variable "key_province" {
  description = "OpenVPN CA Province Name"
}
variable "key_city" {
  description = "OpenVPN CA City Name"
}
variable "key_org" {
  description = "OpenVPN CA Organisation Name"
}
variable "key_email" {
  description = "OpenVPN CA Email Contact"
}
variable "key_ou" {
  description = "OpenVPN Organisation Unit Name"
}
variable "passwd" {
  description = "OpenVPN User Password for AdminUser:openvpn"
}
variable "domain" {
  description = "Domain Name"
}
variable "sslmail" {
  description = "LetsEncrypt Contact Email"
}
variable "owner" {
  description = "AWS Tag for Owner"
}
variable "vpc" {
  description = "AWS VPC to be used"
}
variable "subnetid" {
  description = "Subnet for the EC2 instance"
}
variable "keyname" {
  description = "SSH Access Key"
}
variable "adminurl" {
  description = "OpenVPN Aadmin login"
}
variable "profile" {
  description = "Aws Profile to use"
}