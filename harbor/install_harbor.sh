#!/bin/bash

sudo REQUESTS_CA_BUNDLE=/vagrant/root_ca.crt certbot certonly -n --standalone \ 
    -d harbor.domain \ 
    --server https://ca.domain/acme/acme/directory \
    --agree-tos --email luca.patrignani3@studio.unibo.it

export IPorFQDN=harbor.domain
chmod +x /vagrant/harbor_installer/harbor.sh
/vagrant/harbor_installer/harbor.sh
