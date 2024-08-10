echo "a is client up"

source /vagrant/config/vagrant_config.env

sudo apt-get update && sudo apt-get install coreutils 

# Configure the APT proxy
echo "Acquire::http::Proxy \"http://${PROXY}:3142\";" | sudo tee /etc/apt/apt.conf.d/01proxy


