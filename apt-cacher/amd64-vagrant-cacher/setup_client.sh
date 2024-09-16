#!/bin/bash
echo "Starting Client Configuration..."
sudo apt-get update && sudo apt-get install coreutils 

# Install WireGuard
echo "Installing WireGuard..."
sudo apt install wireguard -y

# Set up the WireGuard configuration
WG_CLIENT_PRIVATE_KEY="WF0dIhF/Ecun5naVcwt9BphssXZ0jHkpzHcEkikef3I="
WG_CLIENT_PUBLIC_KEY=$(echo "$WG_CLIENT_PRIVATE_KEY" | wg pubkey)
WG_CONFIG="/etc/wireguard/wg0.conf"
WG_INTERFACE="wg0"
WG_APT_SERVER_PROXY="10.0.0.1"
CLIENT_IP="10.0.0.2/24"  
SERVER_PUBLIC_KEY="Ekcb/YWSab/pRhVuC5dMKjcKB2ttu5pUtKNBHIhT4FA="
SERVER_ENDPOINT="192.168.1.15:51820"  
ALLOWED_IPS="0.0.0.0/0"  
LIST_PORT="57080"


# Create the WireGuard client configuration file
echo "Creating WireGuard client configuration..."
sudo bash -c "sudo cat > $WG_CONFIG << EOF
[Interface]
PrivateKey = $WG_CLIENT_PRIVATE_KEY
Address = $CLIENT_IP
ListenPort = $LIST_PORT

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_ENDPOINT
AllowedIPs = $ALLOWED_IPS
PersistentKeepalive = 25
EOF"

# Configure firewall (allow WireGuard traffic)
echo "Configuring firewall for WireGuard..."
sudo ufw allow 51820/udp

# Start and enable WireGuard service
echo "Starting WireGuard..."
sudo wg-quick up $WG_INTERFACE
sudo systemctl enable wg-quick@$WG_INTERFACE

# Display the WireGuard public key for client
echo "WireGuard client public key: $WG_CLIENT_PUBLIC_KEY"
echo "Setup complete! WireGuard is up and running."


# Configure the APT proxy
echo "Acquire::http::Proxy \"http://${WG_APT_SERVER_PROXY}:3142\";" | sudo tee /etc/apt/apt.conf.d/01proxy
echo "a is client up"


