#!/usr/bin/env bash

# Install jump
# src: https://github.com/gsamokovarov/jump

if dpkg -s jump &> /dev/null
then
    echo "INFO: jump is already installed"
    exit 0
fi

echo "Installing jump"

wget https://github.com/gsamokovarov/jump/releases/download/v0.30.1/jump_0.30.1_amd64.deb -P /tmp && sudo dpkg -i /tmp/jump_0.30.1_amd64.deb && rm -v /tmp/jump_0.30.1_amd64.deb 