// Instance Name
output "instancename" {
  value = "${aws_instance.openvpnserver.arn}"
}

// Instance Pupblic IPv4
output "publicip" {
  value = "${aws_instance.openvpnserver.public_ip}"
}

// Userdata for OpenVPNServer Setup
output "userdata" {
  value = "${aws_instance.openvpnserver.user_data}"
}

// Instance Private IPv4
output "privateip" {
  value = "${aws_instance.openvpnserver.private_ip}"
}

// Instance Type
output "instancetype" {
  value = "${aws_instance.openvpnserver.instance_type}"
}

// Instance SSH Keyname
output "keyname" {
  value = "${aws_instance.openvpnserver.key_name}"
}

output "adminurl" {
  value       = "https://${aws_route53_record.www.fqdn}/admin"
  description = "Admin Access URL for the OpenVPNServer"
}
