#!/bin/bash

# Install NodeJS

sudo apt-get install curl python-software-properties --yes
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install nodejs --yes
node -v
npm -v