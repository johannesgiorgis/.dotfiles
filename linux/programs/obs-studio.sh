#!/usr/bin/env bash

# Install OBS Studio
# Video recording and live streaming software
# https://obsproject.com/

if dpkg -s obs-studio &> /dev/null
then
    echo "INFO: obs-studio is already installed"
    exit 0
fi

echo "Installing OBS Studio..."

sudo add-apt-repository ppa:obsproject/obs-studio --yes
sudo apt-get update
sudo apt-get install obs-studio --yes

echo "Completed installing OBS Studio"