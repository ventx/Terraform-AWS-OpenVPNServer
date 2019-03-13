variable "ami" {
  description = "ami to be used"
}
variable "instancetype" {
  description = "ec2 instance"
}
variable "instancename" {
  description = "esc instance name"
}
variable "keyname" {
  description = "sshkeyname"
}
variable "sg" {
  description = "security group"
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
  description = "openvpn admin password"
}
variable "domain" {
  description = "openvpn server TLD"
}
variable "sslmail" {
  description = "email for letsencrypt"
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
  description = "OpenVPN Aadmin login"
}

