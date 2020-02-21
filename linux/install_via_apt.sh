#!/usr/bin/env bash

###################################################################
#
# Install Programs via Apt
#
###################################################################

LINE_BREAK="===================================================================================="
function print_stamp() { echo -e "\n$(date +'%F %T') $@"; }


# echo "$LINE_BREAK"
print_stamp "$0 Started"

sudo apt update


function apt_install {
	which $@ &> /dev/null

	if [ $? -ne 0 ]; then
		print_stamp "Installing: ${@}..."
		sudo apt install --yes "${@}"
		print_stamp "Completed installing ${@}!"
	else
		print_stamp "Already installed: ${@}"
	fi
}

# Basics
apt_install awscli python3.7 python3-pip python3-venv xclip curl git tmux vim figlet entr meld jq man zsh tree man

sudo apt upgrade --yes

print_stamp "$0 Completed"