#!/usr/bin/env bash

# Install brave browser
# Brave browser is a fast, private and secure web browser
# https://brave.com/

if dpkg -s brave-browser &> /dev/null
then
    echo "INFO: brave-browser is already installed"
    exit 0
fi

echo "Installing brave-browser..."

# install repository key
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -

# add apt repository
sudo sh -c 'echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com `lsb_release -sc` main" >> /etc/apt/sources.list.d/brave.list'

# refresh system cache & install
sudo apt-get update
sudo apt-get install brave-browser brave-keyring --yes

echo "Completed installing brave-browser"