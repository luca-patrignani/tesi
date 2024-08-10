echo "a is client up"

sudo apt-get update && sudo apt-get install coreutils 

PROXY="192.168.56.10"

# Configure the APT proxy
echo "Acquire::http::Proxy \"http://${PROXY}:3142\";" | sudo tee /etc/apt/apt.conf.d/01proxy


