
#!/usr/bin/env bash

# Intall Sublime Text
# Text Editor
# https://www.sublimetext.com/

if dpkg -s conky-manager &> /dev/null
then
    echo "INFO: sublime-text is already installed"
    exit 0
fi

echo "Installing Sublime Text..."

# install key
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt-get update
sudo apt-get install sublime-text --yes

echo "Completed installing Sublime Text!"
