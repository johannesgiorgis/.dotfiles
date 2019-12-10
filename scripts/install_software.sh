#!/bin/bash

#################################################
#
# Setup Ubuntu Laptop
#
# Version History
# ---------------
#
# 2019-08-06: v0.1
#
#################################################

LINE_BREAK="===================================================================================="
function print_stamp() { echo -e "\n$(date +'%F %T') $@"; }


echo "$LINE_BREAK"
print_stamp "$0 Started"

sudo apt update

function install_snaps {

	echo "Listing installed snaps:"
	snap list

	declare -a snap_software_list=(
		"slack --classic"
		"code --classic"
		"sublime-text --classic"
		"firefox"
		"vlc"
		"simplenote"
		"spotify"
		"whatsdesk"
	)

	echo ''
	echo "Installing Snap Software..."

	# Read the array values with space
	for val in "${snap_software_list[@]}"; do
	print_stamp "Installing '$val': snap install $val"
	sudo snap install $val
	echo "Completed installing $val!"
	done

	echo ''
	echo "Listing installed snaps after installation:"
	snap list
}

function install {
	which $1 &> /dev/null

	if [ $? -ne 0 ]; then
		echo "Installing: ${1}..."
		sudo apt install --yes "${1}"
		echo "Completed installing ${1}!"
	else
		echo "Already installed: ${1}"
	fi
}

# Basics
install awscli
install python3-pip
install xclip
install curl
install git
install tmux
install vim

print_stamp "$0 Completed"
echo "$LINE_BREAK"