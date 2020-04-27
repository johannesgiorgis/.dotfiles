#!/usr/bin/env bash

# Install Docker
# src: https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04
# src: https://www.digitalocean.com/community/questions/how-to-fix-docker-got-permission-denied-while-trying-to-connect-to-the-docker-daemon-socket

echo -e "\nInstalling Docker..."

# Uninstall Old Versions of Docker
# sudo apt-get remove docker docker-engine docker.io

# Install Docker
sudo apt-get install docker.io --yes

# Start and Automate Docker
sudo systemctl start docker
sudo systemctl enable docker

# Check Docker Version
docker --version

# Create the docker group
sudo groupadd docker

# Add your user to the docker group
sudo usermod -aG docker ${USER}

# Ensure your group membership is re-evaluated
su -s ${USER}

echo -e "\nCompleted installing Docker!"