echo "apt-cacher up"

sudo apt-get update -y

# Preconfigure the debconf selections to automatically answer the prompt
echo "apt-cacher-ng apt-cacher-ng/tunnelenable boolean true" | sudo debconf-set-selections

sudo apt-get install -y apt-cacher-ng && sudo echo "PassThroughPattern: .* # this would allow CONNECT to everything" >>  /etc/apt-cacher-ng/acng.conf

# Save the IP address to a file for sharing
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "PROXY=${IP_ADDRESS}" > /vagrant/config/vagrant_config.env

sudo apt-get install -y systemctl 


sudo systemctl enable apt-cacher-ng
sudo systemctl start apt-cacher-ng

sudo systemctl status apt-cacher-ng

#check apt-cacher logs
#tail -f /var/log/apt-cacher-ng/apt-cacher.log
