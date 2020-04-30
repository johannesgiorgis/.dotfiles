#!/usr/bin/env bash

###################################################################
#
# Install Programs via Homebrew
#
###################################################################

LINE_BREAK="===================================================================================="
function print_stamp() { echo -e "\n$(date +'%F %T') $@"; }


main() {
    echo "${LINE_BREAK}"
    print_stamp "$0 Started"
    brew update

    # brew install
    install_general_tools
    install_programming_languages
    install_databases

    # brew cask install
    cask_install_general_tools
    cask_install_note_taking
    cask_install_development_tools
    cask_install_logitech

    # brew custom tap
    brew_custom_install
    
    echo "\n› Running 'brew upgrade' and 'brew cleanup'"
    brew upgrade
    brew cleanup
    
    print_stamp "$0 Completed"
    echo "${LINE_BREAK}"
}


# ################### BREW UTILITIES #################################

function brew_install {
    print_stamp "Installing via brew: '${@}'..."
    brew install "${@}"
	print_stamp "Completed installing via brew: '${@}'!"
}

function brew_cask_install {
    print_stamp "Installing via brew cask: '${@}'..."
    brew cask install "${@}"
    print_stamp "Completed installing via brew cask: '${@}'!"
}


# ################### BREW INSTALL #################################

install_general_tools() {
    brew_install cask
    brew_install htop
    brew_install jq
    brew_install speedtest-cli
    brew_install tldr
    brew_install tree
    brew_install watch
    brew_install wget
    brew_install wifi-password
    brew_install putty
    brew_install csvkit
    brew_install ack
    brew_install jump
    brew_install entr

    # download youtube - ffmpeg needed for converting to audio files :)
    brew_install youtube-dl ffmpeg
}

install_programming_languages() {
    # golang
    brew_install go

    # ruby
    brew_install rbenv

    # python
    brew_install black flake8 pipenv pyenv

    # Additional system dependencies needed for Python compilation by pyenv (optional, but recommended)
    # https://github.com/pyenv/pyenv/wiki
    brew_install openssl readline sqlite3 xz zlib
}

install_databases() {
    brew_install postgresql
    brew_install mysql
}


# ################### BREW CASK #################################

cask_install_general_tools() {
    brew_cask_install dropbox
    brew_cask_install firefox
    brew_cask_install google-chrome
    brew_cask_install vlc
    brew_cask_install zoomus
    brew_cask_install tunnelblick       # vpn
    brew_cask_install omnidisksweeper   # disk utility 
    brew_cask_install rectangle         # mac window management
}

cask_install_note_taking() {
    brew_cask_install simplenote
    brew_cask_install sublime-merge
    brew_cask_install sublime-text
    brew_cask_install joplin 
}

cask_install_development_tools() {
    brew_cask_install iterm2
    brew_cask_install lepton
    brew_cask_install meld
    brew_cask_install postman
    brew_cask_install visual-studio-code
    brew_cask_install pgadmin4
}

cask_install_logitech() {
    brew_cask_install logitech-options logitech-unifying logitech-control-center
}


# ################### BREW CUSTOM #################################

function brew_custom_install {
    print_stamp "Installing via custom brew..."

    echo -e "\n› Installing displacer..."
    brew tap jakehilborn/jakehilborn && brew install displayplacer
    echo -e "\n› Completed installing displacer!"

    echo -e "\n› Installing Fira Code..."
    brew tap homebrew/cask-fonts && brew cask install font-fira-code
    echo -e "\n› Completed installing Fira Code!"

    print_stamp "Completed installing via custom brew!"
}

main