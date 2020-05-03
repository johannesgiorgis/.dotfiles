#!/usr/bin/env bash

# Install VS Code
# src: https://linuxize.com/post/how-to-install-visual-studio-code-on-ubuntu-18-04/

if dpkg -s code &> /dev/null
then
    echo "INFO: VS Code is already installed"
    exit 0
fi

# update the packages index and install the dependencies
sudo apt-get update
sudo apt-get install software-properties-common apt-transport-https wget --yes

# import the Microsoft GPG key
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -

# enable the Visual Studio Code repository
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

# install the latest version of Visual Studio Code
sudo apt-get update
sudo apt-get install code --yes