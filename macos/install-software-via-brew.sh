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
    install_development_tools
    install_databases

    # brew cask install
    cask_install_general_tools
    cask_install_note_taking
    cask_install_development_tools
    cask_install_logitech
    cask_install_media

    # brew custom tap
    brew_custom_install_displacer
    brew_custom_install_font_fira_code

    # install software on work mac
    is_work_mac

    # install software on personal mac
    is_personal_mac

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
    brew_install jq
    brew_install speedtest-cli
    brew_install tldr
    brew_install tree
    brew_install watch
    brew_install wget
    brew_install wifi-password
    brew_install csvkit
    brew_install ack
    brew_install jump
    brew_install entr
    brew_install shellcheck

    # download youtube - ffmpeg needed for converting to audio files :)
    brew_install youtube-dl ffmpeg

    # cat alternative
    brew_install bat

    # ls alternative
    brew_install exa
    brew_install broot
    brew_install fzf

    # diff alternative
    brew_install diff-so-fancy

    # find alternative
    brew_install fd

    # mac app store command line tool
    brew_install mas

    # rename
    brew_install rename

    # grep/ack alternative
    brew_install ripgrep

    # cli messages
    brew_install fortune

    # cli markdown presentation tool
    brew_install mdp

    # trigger notifications in cli
    brew_install noti

    # task/time warrior
    brew_install tasksh
    brew_install timewarrior
    brew_install ansible
    brew_install curl
}

function install_development_tools() {
    # v2.0
    brew_install aws
    brew_install neovim
    brew_install httpie
    brew_install git
    brew_install gnupg
    brew_install pipx
}

function install_programming_languages() {
    # python
    brew_install black
    brew_install flake8
    brew_install pipenv
    brew_install poetry

    # Additional system dependencies needed for Python compilation by pyenv (optional, but recommended)
    # https://github.com/pyenv/pyenv/wiki
    brew_install openssl readline sqlite3 xz zlib

    # brew_install rbenv
}


function install_databases() {
    brew_install postgresql
    brew_install mysql
}


# ################### BREW CASK #################################

function cask_install_general_tools() {
    brew_cask_install dropbox

    # browsers
    brew_cask_install firefox
    brew_cask_install google-chrome
    brew_cask_install brave-browser
    brew_cask_install zoomus
    # disk utility
    brew_cask_install omnidisksweeper
    # mac window management
    brew_cask_install rectangle
    # aerial screen saver
    brew_cask_install aerial
    brew_cask_install lg-onscreen-control   
    # dock manager
    # brew_cask_install vanilla
    brew_cask_install authy
}


function cask_install_note_taking() {
    brew_cask_install simplenote
    brew_cask_install sublime-text
    brew_cask_install joplin 
    brew_cask_install macvim
}


function cask_install_development_tools() {
    brew_cask_install iterm2
    brew_cask_install lepton
    brew_cask_install meld
    brew_cask_install postman
    brew_cask_install visual-studio-code
    brew_cask_install pgadmin4
    brew_cask_install sourcetree
    brew_cask_install sublime-merge
    brew_cask_install beekeeper-studio
    brew_cask_install kite
}


function cask_install_logitech() {
    brew_cask_install logitech-options
    brew_cask_install logitech-unifying
    brew_cask_install logitech-control-center
}

function cask_install_media() {
    brew_cask_install vlc
    brew_cask_install plex
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

# ################### BREW CUSTOM #################################

function is_work_mac() {
    print_info "› Checking if device is Work Mac..."

    user=$(whoami)
    kernel_name=$(uname -s)
    
    if [[ "${kernel_name}" == "Darwin" ]] && [[ "${user}" == "jgiorgis" ]]; then
        warn "This is a work laptop :)"
        install_software_on_work_mac
    else
        warn "This is not a work laptop"
    fi
}

function install_software_on_work_mac() {
    print_info "› Installing Software on Work Mac..."

    # v1.0
    brew_install awscli@1
    brew_install putty
    brew_install telnet
    brew_install pandoc
    brew_install parquet-tools

    # cask
    brew_cask_install alfred
    brew_cask_install jetbrains-toolbox
    # vpn
    brew_cask_install openvpn-connect
    brew_cask_install pycharm
    brew_cask_install tunnelblick
    brew_cask_install karabiner-elements
    brew_cask_install basictex
    brew_cask_install wkhtmltopdf

    # sql server
    install_ms_sql_server

    success "› Completed installing Software on Work Mac!"
}

function install_ms_sql_server() {
    brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
    brew update
    HOMEBREW_NO_ENV_FILTERING=1 ACCEPT_EULA=Y brew install msodbcsql17 mssql-tools
}

function is_personal_mac() {
    print_info "› Checking if device is Personal Mac..."

    user=$(whoami)
    kernel_name=$(uname -s)
    
    if [[ "${kernel_name}" == "Darwin" ]] && [[ "${user}" == "johannes" ]]; then
        warn "This is a personal laptop :)"
        install_software_on_personal_mac
    else
        warn "This is not a personal laptop"
    fi
}

function install_software_on_personal_mac() {
    print_info "› Installing Sofware on Personal Mac..."

    # cask
    brew_cask_install pycharm-ce

    success "› Completed installing on Personal Mac!"
}

main

