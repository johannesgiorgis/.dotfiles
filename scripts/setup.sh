#!/bin/bash


###################################################################
#
# Setup Ubuntu Laptop
#
# Version History
# ---------------
#
# 2020-02-05: v0.1
#
###################################################################

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "SCRIPTS_DIR:$SCRIPTS_DIR"

cd "${SCRIPTS_DIR}"

chmod +x *.sh

# ./symlink.sh
./install_software.sh
# ./install-custom-programs.sh
# ./desktop.sh

# Get all upgrades
sudo apt upgrade -y

# See our bash changes
# source ~/.bashrc

# Fun hello
figlet "... and we're back!" | lolcat