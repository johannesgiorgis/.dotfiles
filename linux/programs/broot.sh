#!/usr/bin/env bash

# Install broot
# A better way to navigate directories
# https://github.com/Canop/broot


if dpkg -s broot &> /dev/null
then
    echo "INFO: broot is already installed"
    exit 0
fi

echo "Installing broot..."

echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -

sudo apt-get update
sudo apt-get install broot --yes

echo "Completed installing broot"