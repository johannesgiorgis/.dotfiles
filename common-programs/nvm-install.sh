#!/usr/bin/env bash

# Install NVM

# nvm is a actually a shell function and thus 
# the test `command -v nvm` cannot work as 
# it doesn't return a file path
# result=$(command -v nvm 2>&1)
# Unable to verify installation to avoid -reinstallation :(

echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
echo "Completed installing nvm!"