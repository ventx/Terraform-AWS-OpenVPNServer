![alt text](https://www.ventx.de/images/logo.png "Ventx Logo")
# Terraform AWS OpenVPNServer
## Range of application
* Deploys an **OpenVPN** and **Access Server** with Letsencrypt SSL Certificate on EC2
* LetsEncrypt hook to put certificate into OpenVPN-AS config and restart openvpnas service



## Basic Settings
Customize your OpenVPNServer with these [Inputs](#Inputs)

## Logoutput on the EC2 Instance
Setup logfile `/tmp/setup.log`

LetsEncrypt auto renew logfile `/var/log/letsencrypt-renew.log`

## Advanced Settings
For VPN Routing and advanced settings use the **Access Server command line interface tools**

To use `./sacli` navigate to `/usr/local/openvpn_as/scripts/ `

Default settings never route any client traffic through the VPN

You can change this in `userdata.sh` befor creating the instance but you also can change this after that on the EC2 Instance.

**sacli commands examples** _(no client traffic routing through the VPN connection)_

 ```bash
  ./sacli --key "vpn.client.routing.reroute_dns" --value "false" ConfigPut
  ./sacli --key "vpn.client.routing.reroute_gw" --value "false" ConfigPut

 ```
## Usage
If everything went well :)  you can access your OpenVPN Access server via your browser.

Check your specified Admin URL in the outputs of this terraform module

Username: `openvpn`

Password: ( set your password with `${var.passwd}`


## Links

* https://openvpn.net/vpn-server-resources/managing-settings-for-the-web-services-from-the-command-line/


### <a name="Inputs"></a> Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | AWS AMI to use | string | ami-090f10efc254eaf55 | no |
| domain | Domain Name | string | n/a | yes |
| instancename | Name of the Instance | string | n/a | yes |
| instancetype | AWS Instance Type | string | n/a | yes |
| key\_city | OpenVPN CA City Name | string | n/a | yes |
| key\_country | OpenVPN CA Country Name | string | n/a | yes |
| key\_email | OpenVPN CA Email Contact | string | n/a | yes |
| key\_org | OpenVPN CA Organisation Name | string | n/a | yes |
| key\_ou | OpenVPN Organisation Unit Name | string | n/a | yes |
| key\_province | OpenVPN CA Province Name | string | n/a | yes |
| keyname | SSH Access Key | string | n/a | yes |
| owner | AWS Tag for Owner | string | n/a | yes |
| passwd | OpenVPN User Password for AdminUser:openvpn | string | n/a | yes |
| profile | Aws Profile to use | string | n/a | yes |
| region | Region to use | string | n/a | yes |
| sslmail | LetsEncrypt Contact Email | string | n/a | yes |
| subdomain | Subdomain | string | n/a | yes |
| subnetid | Subnet for the EC2 instance | string | n/a | yes |
| vpc | AWS VPC to be used | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| Domain Name | TLD for the OpenVPNServer |
| adminurl | Admin Access URL for the OpenVPNServer |
| arn | Your VPC ARN |
| instancearn | Instance ARN |
| instancetype | Instance Type |
| iprange | VPC Iprage |
| keyname | SSH Access Key Name |
| privateip | Instance Private IP |
| pubplicip | The Instance Public IP |
| route table | Route Table |
| sg\_id | SecurityGroup ID |
| sg\_name | SecurityGroup Name |
| userdata | Userdata Hash |
| vpc\_id | VPC ID |
| vpc\_name | VPC Name |
