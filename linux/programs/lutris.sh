#!/usr/bin/env bash

# Install Lutris
# Open Source gaming platform for Linux
# https://lutris.net/

if dpkg -s lutris &> /dev/null
then
    echo "INFO: lutris is already installed"
    exit 0
fi

echo "Installing Lutris..."

sudo add-apt-repository ppa:lutris-team/lutris --yes
sudo apt-get update
sudo apt-get install lutris --yes

echo "Completed installing Lutris"
