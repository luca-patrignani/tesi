#!/bin/bash

apt update
apt install jq -y

mkdir -p /tmp/stepbin

cd /tmp/stepbin

wget https://github.com/smallstep/cli/releases/download/v0.18.2/step_linux_0.18.2_amd64.tar.gz -O step-cli.tar.gz
wget https://github.com/smallstep/certificates/releases/download/v0.18.2/step-ca_linux_0.18.2_amd64.tar.gz -O step-ca-cli.tar.gz

tar zxvf step-cli.tar.gz
tar zxvf step-ca-cli.tar.gz

rm -f *.tar.gz

chmod a+x step*/bin/*

cp step*/bin/* /usr/local/bin/

mkdir -p /root/.step
echo Ciao1ciao > /root/.step/.ca-pw

step ca init \
    --name=luca \
    --dns=ca.domain \
    --address=$(hostname -I | cut -d ' ' -f 2):443 \
    --provisioner=luca.patrignani3@studio.unibo.it \
    --provisioner-password-file=/root/.step/.ca-pw \
    --password-file=/root/.step/.ca-pw

cat > /etc/systemd/system/step-ca-server.service <<EOF
[Unit]
Description=Step CA Server
After=network-online.target
Wants=network-online.target

[Service]
TimeoutStartSec=0
ExecStart=/usr/local/bin/step-ca --password-file=/root/.step/.ca-pw /root/.step/config/ca.json
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/bin/kill -TERM $MAINPID
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable --now step-ca-server

step ca provisioner add acme --type ACME --claims '{"maxTLSCertDuration": "4320h", "defaultTLSCertDuration": "744h"}'
step ca provisioner add x5c-smallstep --type X5C --x5c-root /root/.step/certs/root_ca.crt
cp /root/.step/config/ca.json /root/.step/config/ca.json.bak

jq '.authority.provisioners[[.authority.provisioners[] | .type=="JWK"] | index(true)].claims |= (. + {"maxTLSCertDuration":"8760h","defaultTLSCertDuration":"744h"})' /root/.step/config/ca.json.bak > /root/.step/config/ca.json
systemctl restart step-ca-server

step certificate install /root/.step/certs/root_ca.crt
cp /root/.step/certs/root_ca.crt /vagrant/
