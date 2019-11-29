#!/bin/bash
##########################################
# Install OpenVPN Server on Ubuntu 18.04 #
#             by ventx GmbH              #
##########################################

# Path for openvpn vars
vars="/home/ubuntu/openvpn-ca/vars"

export DEBIAN_FRONTEND=noninteractive

# Starting Setup
echo "=======[ Installation started ]====="
echo "=======| 1. Update, upgrade and install tools"
apt-get update
apt-get upgrade -q -y | tee -a
apt-get install ca-certificates chrony wget net-tools -y

echo "=======| 2. Install certbot, openvpn-as and mysql-client"
echo "deb http://as-repository.openvpn.net/as/debian bionic main" > /etc/apt/sources.list.d/openvpn-as-repo.list
wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | apt-key add -
add-apt-repository ppa:certbot/certbot -y
apt-get update
apt-get install certbot easy-rsa openssl openvpn-as python3-pip -q -y
pip3 install awscli

echo "=======| 3. Set Amazon Time Sync Service in Chrone on Ubuntu"
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html#configure-amazon-time-service-ubuntu
sed -i '/^pool ntp.ubuntu.com\s*iburst maxsources 4.*/i server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4' /etc/chrony/chrony.conf
systemctl restart chrony

echo "=======| 4. Create openvpn-ca dir"
make-cadir /home/ubuntu/openvpn-ca
mkdir -p /home/ubuntu/openvpn-ca/keys

echo "=======| 5. Create openssl config from default"
cp /home/ubuntu/openvpn-ca/openssl-1.*.cnf /home/ubuntu/openvpn-ca/openssl.cnf

# RANDFILE not needed for OpenSSL >=1.1.1 anymore
# https://github.com/openssl/openssl/issues/7754
sed -i '/^RANDFILE/ d' /home/ubuntu/openvpn-ca/openssl.cnf

chown -R ubuntu: /home/ubuntu/openvpn-ca/ && chmod 755 -R /home/ubuntu/openvpn-ca/
cd /home/ubuntu/openvpn-ca/ || exit

echo "=======| 6. Empty openvpn-ca/vars"
truncate -s0 $vars

echo "=======| 7. Set variables for OpenVPN"
{
    echo export EASY_RSA="/home/ubuntu/openvpn-ca";
    echo export OPENSSL="$(command -v openssl)";
    echo export PKCS11TOOL="$(command -v pkcs11-tool)";
    echo export GREP="$(command -v grep)";
    echo export KEY_CONFIG="$(/home/ubuntu/openvpn-ca/whichopensslcnf /home/ubuntu/openvpn-ca)";
} >> $vars

{
    echo export KEY_DIR="/home/ubuntu/openvpn-ca/keys";
    echo export PKCS11_MODULE_PATH="dummy";
    echo export PKCS11_PIN="dummy";
    echo export KEY_SIZE=2048;
    echo export CA_EXPIRE=1825;
    echo export KEY_EXPIRE=1825;
    echo export KEY_COUNTRY="${key_country}";
    echo export KEY_PROVINCE="${key_province}";
    echo export KEY_CITY="${key_city}";
    echo export KEY_ORG="${key_org}";
    echo export KEY_EMAIL="${key_email}";
    echo export KEY_OU="${key_ou}";
    echo export KEY_NAME="openvpnserver";
} >> $vars

echo "=======| 8. Source vars"
source /home/ubuntu/openvpn-ca/vars

echo "=======| 9. Run clean-all"
/home/ubuntu/openvpn-ca/clean-all

echo "=======| 10. Run build- commands provided by OpenVPN"
/home/ubuntu/openvpn-ca/build-ca --batch
/home/ubuntu/openvpn-ca/build-key-server --batch openvpnserver
/home/ubuntu/openvpn-ca/build-dh

#echo "=======| 11. Create Key"
#openvpn --genkey --secret keys/ta.key

echo "=======| 11. Generate a Client Certificate and Key Pair"
/home/ubuntu/openvpn-ca/build-key --batch client1

echo "=======| 12. Request LetsEncrypt Certificate"
certbot certonly --standalone \
  --non-interactive \
  --preferred-challenges http \
  --domains "${subdomain}"."${domain}" \
  --no-eff-email  \
  --agree-tos \
  --email "${sslmail}"

echo "=======| 13. Setup OpenVPN AS EC2 show routes"

echo "sa.show_c2s_routes=true" >> /usr/local/openvpn_as/etc/as.conf

echo "=======| 14. Set Openvpn admin password"
echo -e ""${passwd}"\n"${passwd}"" | passwd openvpn

echo "=======| 15. Settings up OpenVPN Routing"
/usr/local/openvpn_as/scripts/sacli --key "host.name" --value ${subdomain}.${domain} ConfigPut
/usr/local/openvpn_as/scripts/sacli --key "vpn.client.routing.reroute_dns" --value "true" ConfigPut
/usr/local/openvpn_as/scripts/sacli --key "vpn.client.routing.reroute_gw" --value "true" ConfigPut

echo "=======| 16. OpenVPN sacli Config"
/usr/local/openvpn_as/scripts/sacli ConfigQuery
/usr/local/openvpn_as/scripts/sacli start
/usr/local/openvpn_as/scripts/sacli --key "cs.cert" --value_file "/etc/letsencrypt/live/"${subdomain}"."${domain}"/cert.pem" ConfigPut
/usr/local/openvpn_as/scripts/sacli --key "cs.ca_bundle" --value_file "/etc/letsencrypt/live/"${subdomain}"."${domain}"/chain.pem" ConfigPut
/usr/local/openvpn_as/scripts/sacli --key "cs.priv_key" --value_file "/etc/letsencrypt/live/"${subdomain}"."${domain}"/privkey.pem" ConfigPut
chown ubuntu: /home/ubuntu/openvpn-ca/keys/
chmod 755 -R  /home/ubuntu/openvpn-ca/keys/


echo "=======| 21. SSL Autorenew crontab entry"
crontab -l | { cat; echo "40 3 * * 0 letsencrypt renew >> /var/log/letsencrypt-renew.log"; } | crontab -

echo "=======| 22. LetsEncrypt renewal-hook"
cat << 'EOF' > /etc/letsencrypt/renewal-hooks/deploy/01-configput-openvpn-and-reload
#!/usr/bin/env bash
set -e
/usr/local/openvpn_as/scripts/sacli --key \"cs.cert\" --value_file \"/etc/letsencrypt/live/${subdomain}.${domain}/cert.pem\" ConfigPut
echo "/usr/local/openvpn_as/scripts/sacli --key \"cs.ca_bundle\" --value_file \"/etc/letsencrypt/live/${subdomain}.${domain}/chain.pem\" ConfigPut
echo "/usr/local/openvpn_as/scripts/sacli --key \"cs.priv_key\" --value_file \"/etc/letsencrypt/live/${subdomain}.${domain}/privkey.pem\" ConfigPut
echo "systemctl restart openvpnas
EOF

echo "=======| 23. Restart OpenVPN AS"
systemctl restart openvpnas
echo "==============END OF Installation============="