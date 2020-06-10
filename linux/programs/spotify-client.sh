#!/usr/bin/env bash

# Intall Spotify
# Music Player
# https://www.spotify.com/

if dpkg -s spotify-client &> /dev/null
then
    echo "INFO: spotify-client is already installed"
    exit 0
fi

echo "Installing Spotify..."

# Import Spotify signing key
wget -O- https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -

# Add official Spotify respository
sudo add-apt-repository "deb http://repository.spotify.com stable non-free" -y

# Install Spotify
sudo apt install spotify-client -y

echo "Completed installing Spotify"