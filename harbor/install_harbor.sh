#!/bin/bash

snap install --classic certbot

systemctl stop docker

IPorFQDN=harbor.domain

REQUESTS_CA_BUNDLE=/vagrant/root_ca.crt certbot certonly \
    -n --standalone \
    -d $IPorFQDN \
    --server https://ca.domain/acme/acme/directory \
    --agree-tos --email luca.patrignani3@studio.unibo.it


# Housekeeping
apt update -yq
swapoff --all
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
#ufw disable #Do Not Do This In Production
echo "Housekeeping done"

#Install Latest Stable Docker Release
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -yqq
apt-get install -y docker-ce docker-ce-cli containerd.io
tee /etc/docker/daemon.json >/dev/null <<EOF
{
	"exec-opts": ["native.cgroupdriver=systemd"],
	"insecure-registries" : ["$IPorFQDN:443","$IPorFQDN:80","0.0.0.0/0"],
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "100m"
	},
	"storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
groupadd -f docker
MAINUSER=$(logname)
usermod -aG docker $MAINUSER
systemctl daemon-reload
systemctl restart docker
echo "Docker Installation done"

#Install Latest Stable Docker Compose Release
curl -skL $(curl -s https://api.github.com/repos/docker/compose/releases/latest|grep browser_download_url|grep -i "$(uname -s)-$(uname -m)"|grep -v sha25|head -1|cut -d'"' -f4) -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || true
echo "Docker Compose Installation done"

#Install Latest Stable Harbor Release
wget -q $(curl -s https://api.github.com/repos/goharbor/harbor/releases/latest|grep browser_download_url|grep online|cut -d'"' -f4|grep '.tgz$'|head -1) -O harbor-online-installer.tgz
tar xvf harbor-online-installer.tgz

cd harbor
cp /vagrant/harbor.yml harbor.yml
sed -i "s/reg.mydomain.com/$IPorFQDN/g" harbor.yml

mkdir -p /var/log/harbor
./install.sh --with-trivy
# cp /vagrant/root_ca.crt /home/vagrant/harbor/common/config/shared/trust-certificates
echo -e "Harbor Installation Complete \n\nPlease log out and log in or run the command 'newgrp docker' to use Docker without sudo\n\nLogin to your harbor instance:\n docker login -u admin -p Harbor12345 $IPorFQDN\n\n:::: ufw firewall was NOT disabled!\n"

exit_code=0
while [[ exit_code -ne 200 ]]; do 
	exit_code=$( curl -X PUT -s -o /vagrant/set_ldap_harbor.out -w "%{http_code}" -u "admin:Harbor12345" -H "Content-Type: application/json" \
		-ki https://harbor.domain/api/v2.0/configurations \
		-d '{
		"auth_mode": "ldap_auth",
		"ldap_url": "ldap://ldap.domain:3890",
		"ldap_base_dn": "ou=people,dc=ldap.domain",
		"ldap_search_dn": "uid=admin,ou=people,dc=ldap.domain",
		"ldap_search_password": "password",
		"ldap_group_base_dn": "ou=groups,dc=ldap.domain",
		"ldap_group_admin_dn": "cn=group,ou=groups,dc=ldap.domain",
		"ldap_group_search_filter": "(objectClass=groupOfUniqueNames)",
		"ldap_group_attribute_name": "uid",
		"ldap_uid": "uid"
		}' )
	sleep 2
done
