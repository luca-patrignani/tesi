#!/bin/bash
# Fetch APT-Cacher NG IP address dynamically
PROXY=$(vagrant ssh apt-cacher -c "hostname -I | awk '{print \$1}'")
vagrant up
