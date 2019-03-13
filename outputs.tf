output "arn" {
  value = "${data.aws_vpc.target.arn}"
  description ="Your VPC ARN"
}
output "iprange" {
  value = "${data.aws_vpc.target.cidr_block}"
  description ="VPC Iprage"
}
output "route table" {
  value = "${data.aws_vpc.target.main_route_table_id}"
  description ="Route Table"
}
output "instancearn" {
  value = "${module.openvpninstance.instancename}"
  description ="Instance ARN"
}
output "pubplicip" {
  value = "${module.openvpninstance.publicip}"
  description ="The Instance Public IP"
}
output "userdata" {
  value = "${module.openvpninstance.userdata}"
  description ="Userdata Hash"
}
output "sg_id" {
  value = "${aws_security_group.vpnsecuritygroup.id}"
  description ="SecurityGroup ID"
}
output "sg_name" {
  value = "${aws_security_group.vpnsecuritygroup.name}"
  description ="SecurityGroup Name"
}
output "vpc_id" {
  value = "${data.aws_vpc.target.id}"
  description ="VPC ID"
}
output "vpc_name" {
  value = "${data.aws_vpc.target.arn}"
  description ="VPC Name"
}
output "privateip" {
  value = "${module.openvpninstance.privateip}"
  description ="Instance Private IP"
}
output "Domain Name" {
  value = "${aws_route53_record.www.fqdn}"
  description ="TLD for the OpenVPNServer"
}
output "adminurl" {
  value = "https://${aws_route53_record.www.fqdn}/admin"
  description ="Admin Access URL for the OpenVPNServer"
}
output "instancetype" {
  value = "${module.openvpninstance.instancetype}"
  description ="Instance Type"
}
output "keyname" {
  value = "${module.openvpninstance.keyname}"
  description ="SSH Access Key Name"
}

