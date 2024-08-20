#!/bin/bash

snap install --classic certbot

REQUESTS_CA_BUNDLE=/vagrant/root_ca.crt certbot certonly \
    -n --standalone \
    -d ldap.domain \
    --server https://ca.domain/acme/acme/directory \
    --agree-tos --email luca.patrignani3@studio.unibo.it

#Install Latest Stable Docker Release
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -yqq
apt-get install -y docker-ce docker-ce-cli containerd.io



mkdir -p /etc/systemd/system/docker.service.d
groupadd -f docker
MAINUSER=$(logname)
usermod -aG docker $MAINUSER
systemctl daemon-reloads
systemctl restart docker
echo "Docker Installation done"

#Install Latest Stable Docker Compose Release
curl -skL $(curl -s https://api.github.com/repos/docker/compose/releases/latest|grep browser_download_url|grep -i "$(uname -s)-$(uname -m)"|grep -v sha25|head -1|cut -d'"' -f4) -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || true
echo "Docker Compose Installation done"

cd /vagrant/ldap
mkdir lldap_data
cp /etc/letsencrypt/live/ldap.domain/{fullchain,privkey}.pem lldap_data/
sudo docker compose up -d
