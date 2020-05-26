#!/usr/bin/env bash

# Install Wine
# Allow running Windows applications on POSIX-compliant OS
# https://www.winehq.org/

if dpkg -s winehq-stable &> /dev/null
then
    echo "INFO: winehq-stable is already installed"
    exit 0
fi

echo "Installing Wine..."

# enable 32 bit architecture
sudo dpkg --add-architecture i386 

# Download and add the repository key
wget -nv -O - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -

codename=$(lsb_release -cs)

sudo add-apt-repository "deb https://dl.winehq.org/wine-builds/ubuntu/  ${codename} main" --yes


# install wine 5.0 on ubuntu 18.04
# https://nixytrix.com/error-winehq-stable-depends-wine-stable-5-0-0-bionic/

# Add the OBS faudio repository
wget -nv -O - https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key | sudo apt-key add -

sudo apt-add-repository 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/ ./'


sudo apt-get update


# Stable branch
sudo apt-get install --install-recommends winehq-stable --yes

echo "Completed installing Wine"
