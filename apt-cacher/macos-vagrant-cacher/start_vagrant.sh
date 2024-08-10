#!/bin/bash
# when vagrant is playing dumb on macosx
sudo launchctl stop com.vagrant.vagrant-vmware-utility
sudo launchctl start com.vagrant.vagrant-vmware-utility
