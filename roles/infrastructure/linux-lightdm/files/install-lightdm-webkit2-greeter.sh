#!/usr/bin/env bash

# Install lightdm-webkit2-greeter
# https://software.opensuse.org/download.html?project=home:antergos&package=lightdm-webkit2-greeter

if dpkg -s lightdm-webkit2-greeter &> /dev/null
then
  echo "INFO: lightdm-webkit2-greeter is already installed"
  exit 0
fi

echo 'adding repository'
echo 'deb http://download.opensuse.org/repositories/home:/antergos/Debian_9.0/ /' | sudo tee /etc/apt/sources.list.d/home:antergos.list

echo 'getting gpg key...'
curl -fsSL https://download.opensuse.org/repositories/home:antergos/Debian_9.0/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home:antergos.gpg > /dev/null

echo 'updating cache...'
sudo apt update

echo 'installing lightdm-webkit2-greeter...'
sudo apt install lightdm-webkit2-greeter
echo 'completed installing lightdm-webkit2-greeter!'