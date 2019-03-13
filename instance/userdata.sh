#!/bin/bash
##########################################
# Install OpenVPN Server on Ubuntu 18.04 #
#              Ventx GmbH                #
##########################################

# Path for Setup Logfile
log="/tmp/setup.log"

# Path for openvpn vars
vars="/home/ubuntu/openvpn-ca/vars"

# Starting Setup
echo "=======Installation started=====" > $log
echo "=======1. Updating Sourcelists=======" >> $log
sudo apt-get update -y  >> $log
echo  >> $log
echo "=======2. Installing openvpn and easy rda=======" >> $log
sudo apt-get install openvpn easy-rsa openssl net-tools -y  >> $log
echo  >> $log
echo "=======3. Create openvpn-ca folder=======" >> $log
make-cadir /home/ubuntu/openvpn-ca
chown ubuntu: /home/ubuntu/openvpn-ca/
chmod 755 -R /home/ubuntu/openvpn-ca/
chown ubuntu: /home/ubuntu/openvpn-ca/keys/
chmod 755 -R  /home/ubuntu/openvpn-ca/keys/
echo  >> $log
echo "=======4. Go to openvpn-ca/=======" >> $log
cd /home/ubuntu/openvpn-ca/
echo  >> $log
echo "=======5. Empty file openvpn-ca/vars=======" >> $log
truncate -s0 $vars
echo  >> $log
echo "=======6. Get Vars from Terraform======" >> $log
echo export EASY_RSA='"`pwd`"' >> $vars
echo export OPENSSL='"openssl"' >> $vars
echo export PKCS11TOOL='"pkcs11-tool"' >> $vars
echo export GREP='"grep"' >> $vars
echo export KEY_CONFIG='"`$EASY_RSA/whichopensslcnf $EASY_RSA`"' >> $vars
define
echo export KEY_DIR='"$EASY_RSA/keys"' >> $vars
echo export PKCS11_MODULE_PATH='"dummy"' >> $vars
echo export PKCS11_PIN='"dummy"' >> $vars
echo export KEY_SIZE=2048 >> $vars
echo export CA_EXPIRE=3650 >> $vars
echo export KEY_EXPIRE=3650 >> $vars
echo export KEY_COUNTRY= '"${key_country}"' >> $vars
echo export KEY_PROVINCE='"${key_province}"' >> $vars
echo export KEY_CITY='"${key_city}"' >> $vars
echo export KEY_ORG='"${key_org}"' >> $vars
echo export KEY_EMAIL='"${key_email}"' >> $vars
echo export KEY_OU='"${key_ou}"' >> $vars
echo export KEY_NAME='"openvpnserver"' >> $vars
echo  >> $log
echo "=======7. Write openvpn-ca/vars=======" >> $log
cat $vars >> $log
echo  >> $log
echo "=======8. Rename openssl cnf=======" >> $log
mv openssl-1.0.0.cnf openssl.cnf
echo  >> $log
echo "=======9. Run source vars command=======" >> $log
source ./vars  >> $log
source vars  >> $log
echo  >> $log
echo "=======10. Run clean-all command=======" >> $log
./clean-all  >> $log
echo  >> $log
echo "=======11. Run build-ca=======" >> $log
./build-ca --batch  >> $log
echo  >> $log
echo "=======12. Run build-ca=======" >> $log
./build-key-server --batch openvpnserver
echo  >> $log
echo "=======13. Building Diffie-Hellman keys=======" >> $log
./build-dh >> $log
echo  >> $log
echo "=======14. TLS integrity=======" >> $log
openvpn --genkey --secret keys/ta.key
echo  >> $log
echo "=======15. Generate a Client Certificate and Key Pair======" >> $log
cd /home/ubuntu/openvpn-ca
source vars
./build-key --batch client1
echo  >> $log
echo "=======16. Copy the Files to the OpenVPN Directory======" >> $log
cd /home/ubuntu/openvpn-ca/keys
sudo cp ca.crt server.crt server.key ta.key dh2048.pem /etc/openvpn
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | sudo tee /etc/openvpn/server.conf
echo  >> $log
echo "=======17. Firewall======" >> $log
sudo ufw allow 1194/udp >> $log
sudo ufw allow OpenSSH >> $log
sudo ufw allow 80 >> $log
echo  >> $log
echo "=======18. Setup OpenVPN AS Server======" >> $log
curl -O -L -V https://openvpn.net/downloads/openvpn-as-latest-ubuntu18.amd_64.deb
sha256sum openvpn-as-* >> $log
sudo dpkg -i openvpn-as-*.deb
echo  >> $log
echo "=======19. Start Letsencrypt======" >> $log
sudo add-apt-repository ppa:certbot/certbot -y >> $log
sudo apt update >> $log
sudo apt install certbot -y >> $log
echo  >> $log
echo "=======20. Request SSL Certificate======" >> $log
sudo certbot certonly --standalone --preferred-challenges http -d "${subdomain}"."${domain}" --no-eff-email --non-interactive --agree-tos --email "${sslmail}" >> $log
echo  >> $log
echo  "======Letsencrypt debug vars======" >> $log
echo  >> $log
echo "SSL Domain -> ${subdomain}.${domain}" >> $log
echo "LetsEncrypt Email -> ${sslmail}" >> $log
echo  >> $log
echo  "======21. Letsencrypt debug vars======" >> $log
echo "=======22. Setup OpenVPN Web access======" >> $log
#sudo ovpn-init --batch --verbose  >> $log
echo "=======23. Set Openvpn admin password======" >> $log
sudo echo -e ""${passwd}"\n"${passwd}"" | passwd openvpn
echo "${passwd}" >> $log
echo  >> $log
echo "=======24. Setup SSL for OpenVPNServer======" >> $log
cd  /usr/local/openvpn_as/scripts/
sudo ./sacli --key "cs.cert" --value_file "/etc/letsencrypt/live/"${subdomain}"."${domain}"/cert.pem" ConfigPut >> $log
sudo ./sacli --key "cs.ca_bundle" --value_file "/etc/letsencrypt/live/"${subdomain}"."${domain}"/chain.pem" ConfigPut >> $log
sudo ./sacli --key "cs.priv_key" --value_file "/etc/letsencrypt/live/"${subdomain}"."${domain}"/privkey.pem" ConfigPut >> $log
chown ubuntu: /home/ubuntu/openvpn-ca/keys/
chmod 755 -R  /home/ubuntu/openvpn-ca/keys/
echo "=======25. Get PublicIP======" >> $log
public_ip=$(curl http://checkip.amazonaws.com) >> $log
echo "-> Public IP = $public_ip" >> $log
echo  >> $log
echo "=======26. Settings up OpenVPN Routing======" >> $log
sudo ./sacli --key $public_ip --value eth0 ConfigPut >> $log
sudo ./sacli --key "host.name" --value "${subdomain}"."${domain}" ConfigPut >> $log
sudo ./sacli --key "vpn.client.routing.reroute_dns" --value "false" ConfigPut >> $log
sudo ./sacli --key "vpn.client.routing.reroute_gw" --value "false" ConfigPut >> $log
cd /usr/local/openvpn_as/scripts
echo  >> $log
echo "=======26. OpenVPN sacli Config ======" >> $log
sudo ./sacli ConfigQuery >> $log
echo "=======26. EN OpenVPN sacli Config ======" >> $log
sudo ./sacli start
echo  >> $log
echo "=======27. SSL Autorenew crontab entry======" >> $log
crontab -l | { cat; echo "40 3 * * 0 letsencrypt renew >> /var/log/letsencrypt-renew.log"; } | crontab -
echo  >> $log
echo "==============END OF Installation=============" >> $log





