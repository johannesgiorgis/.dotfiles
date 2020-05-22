#!/usr/bin/env bash

###################################################################
#
# Install Programs via Homebrew
#
###################################################################

export SUPPORT_DIR="${HOME}/.dotfiles/support"
source "${SUPPORT_DIR}/common-utilities.sh"


main() {
    start=$(date +%s)
    echo "${LINE_BREAK}"
    print_info "$0 Started"
    brew_update

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
    brew_custom_install_displacer
    brew_custom_install_font_fira_code

    brew_upgrade_cleanup
    
    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
}


# ################### BREW UTILITIES #################################

function brew_update() {
    print_info "› Running 'brew update'..."
    brew update
    success "› Completed running 'brew update'!"
}


function brew_install() {
    print_info "› Installing via brew: '${@}'..."
    brew install "${@}"
	success "› Completed installing via brew: '${@}'!"
}


function brew_cask_install() {
    print_info "› Installing via brew cask: '${@}'..."
    brew cask install "${@}"
    success "› Completed installing via brew cask: '${@}'!"
}


function brew_upgrade_cleanup() {
    print_info "› Running 'brew upgrade' and 'brew cleanup'"
    brew upgrade
    brew cleanup
    success "› Completed running 'brew upgrade' and 'brew cleanup'!"
}


# ################### BREW INSTALL #################################

function install_general_tools() {
    brew_install cask
    brew_install coreutils
    brew_install gpg
    brew_install htop
    # brew_install jq
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
    brew_install shellcheck

    # download youtube - ffmpeg needed for converting to audio files :)
    brew_install youtube-dl ffmpeg
}


function install_programming_languages() {
    # python
    brew_install black flake8 pipenv

    # Additional system dependencies needed for Python compilation by pyenv (optional, but recommended)
    # https://github.com/pyenv/pyenv/wiki
    brew_install openssl readline sqlite3 xz zlib
}


function install_databases() {
    # brew_install postgresql
    # brew_install mysql
}


# ################### BREW CASK #################################

function cask_install_general_tools() {
    brew_cask_install dropbox
    brew_cask_install firefox
    brew_cask_install google-chrome
    brew_cask_install vlc
    brew_cask_install zoomus
    brew_cask_install tunnelblick       # vpn
    brew_cask_install omnidisksweeper   # disk utility 
    brew_cask_install rectangle         # mac window management
}


function cask_install_note_taking() {
    brew_cask_install simplenote
    brew_cask_install sublime-merge
    brew_cask_install sublime-text
    brew_cask_install joplin 
}


function cask_install_development_tools() {
    brew_cask_install iterm2
    brew_cask_install lepton
    brew_cask_install meld
    brew_cask_install postman
    brew_cask_install visual-studio-code
    brew_cask_install pgadmin4
    brew_cask_install sourcetree
}


function cask_install_logitech() {
    brew_cask_install logitech-options
    brew_cask_install logitech-unifying
    brew_cask_install logitech-control-center
}


# ################### BREW CUSTOM #################################


function brew_custom_install_displacer() {
    print_info "› Installing displacer..."
    brew tap jakehilborn/jakehilborn && brew install displayplacer
    success "› Completed installing displacer!"
}


function brew_custom_install_font_fira_code() {
    print_info "› Installing Font Fira Code..."
    brew tap homebrew/cask-fonts && brew cask install font-fira-code
    success "› Completed installing Font Fira Code!"
}

main