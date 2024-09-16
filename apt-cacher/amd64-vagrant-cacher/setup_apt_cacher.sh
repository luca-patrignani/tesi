echo "Apt-cacher server starting..."

sudo apt-get update -y

# Preconfigure the debconf selections to automatically answer the prompt
echo "apt-cacher-ng apt-cacher-ng/tunnelenable boolean true" | sudo debconf-set-selections

sudo apt-get install -y apt-cacher-ng && sudo echo "PassThroughPattern: .*\nBindAddress: 10.0.0.1 " >>  /etc/apt-cacher-ng/acng.conf

# Install apt-cacher-ng for caching and wireguard for security 
sudo systemctl enable apt-cacher-ng
sudo systemctl start apt-cacher-ng
sudo apt install -y wireguard

# Set up WireGuard configuration
WG_PRIVATE_KEY="iCKzT6IxvB+bHKB1sNQHRbqCKn0swgeO7SnlxYrHRlE="
WG_PUBLIC_KEY=$(echo "$WG_CLIENT_PRIVATE_KEY" | wg pubkey)
WG_CONFIG="/etc/wireguard/wg0.conf"
WG_INTERFACE="wg0"
SERVER_IP="10.0.0.1/24"
LISTEN_PORT="51820"
PEER_IP="10.0.0.2/32"

# create WireGuard configuration file
sudo bash -c "sudo cat > $WG_CONFIG << EOF
[Interface]
PrivateKey = $WG_PRIVATE_KEY
Address = $SERVER_IP
ListenPort = $LISTEN_PORT

# Enable IP forwarding for routing
PostUp = iptables -A FORWARD -i $WG_INTERFACE -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i $WG_INTERFACE -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# Add the peer (client) details
PublicKey = CLTNMIfh/Er7VlfV6ikTdEWPoG9767+ABrx181aIKwE=
AllowedIPs = $PEER_IP
EOF"

# Enable IP forwarding
echo "Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo bash -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'

# Configure firewall (allow WireGuard traffic)
echo "Configuring firewall for WireGuard..."
sudo ufw allow $LISTEN_PORT/udp

# Start and enable WireGuard service
echo "Starting WireGuard..."
sudo wg-quick up $WG_INTERFACE
sudo systemctl enable wg-quick@$WG_INTERFACE
D FORWARD -i $WG_INTERFACE -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

sudo systemctl status apt-cacher-ng
sudo systemctl status wireguard

echo "Apt-cacher server loaded"

#check apt-cacher logs
#tail -f /var/log/apt-cacher-ng/apt-cacher.log
