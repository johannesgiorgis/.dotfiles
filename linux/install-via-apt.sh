#!/usr/bin/env bash

###################################################################
#
# Install Programs via Apt
# ------------------------
#
###################################################################

export SUPPORT_DIR="${HOME}/.dotfiles/support"
source "${SUPPORT_DIR}/common-utilities.sh"


main() {
    start=$(date +%s)
	echo "$LINE_BREAK"
	start "$0 Started"

    apt_update

    # Basics
	install_general_tools
    
    sudo apt-get upgrade --yes
    
    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
}


# ################### APT UTILITIES #################################

function apt_update() {
    print_info "› Running 'apt-get update'..."
    sudo apt-get update
    success "› Completed running 'apt-get update'!"
}

function apt_install() {
	which $@ &> /dev/null

	if [ $? -ne 0 ]; then
		print_info "› Installing: ${@}..."
		sudo apt-get install --yes "${@}"
		success "› Completed installing ${@}!"
	else
		print_info "› Already installed: ${@}"
	fi
}


# ################### BREW INSTALL #################################

function install_general_tools() {
    print_info "› installing general tools"
    apt_install ack
    apt_install curl
    apt_install entr
    apt_install figlet
    apt_install git
    apt_install jq
    apt_install man
    apt_install meld
    apt_install rename
    apt_install tldr
    apt_install tmux
    apt_install tree
    apt_install vim
    apt_install xclip
    apt_install zsh
    success "› installing general tools"
}



main