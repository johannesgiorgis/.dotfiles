#!/usr/bin/env bash

###################################################################
#
# Install Programs via Apt
# ------------------------
#
###################################################################

export SUPPORT_DIR="${HOME}/.dotfiles/support"
source "${SUPPORT_DIR}/common_utilities.sh"


main() {
    start=$(date +%s)
	echo "$LINE_BREAK"
	print_stamp "$0 Started"

	sudo apt-get update

    # Basics
	apt_install xclip
	apt_install curl
	apt_install git
	apt_install tmux
	apt_install vim
	apt_install figlet
	apt_install entr
	apt_install meld
	apt_install jq
	apt_install man
	apt_install zsh
	apt_install tree
	apt_install man
    
    sudo apt-get upgrade --yes
    
    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
}


function apt_install {
	which $@ &> /dev/null

	if [ $? -ne 0 ]; then
		print_stamp "Installing: ${@}..."
		sudo apt-get install --yes "${@}"
		print_stamp "Completed installing ${@}!"
	else
		print_stamp "Already installed: ${@}"
	fi
}

main