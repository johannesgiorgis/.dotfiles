#!/usr/bin/env bash

# Install Conky Manager
# GUI for managing Conky config files
# https://teejeetech.in/conky-manager/

if dpkg -s conky-manager &> /dev/null
then
    echo "INFO: conky-manager is already installed"
    exit 0
fi

echo "Installing Conky Manager..."

sudo add-apt-repository ppa:mark-pcnetspec/conky-manager-pm9 --yes
sudo apt-get update
sudo apt-get install conky-manager --yes

echo "Completed installing Conky Manager"