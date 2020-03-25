
###################################################################
#
# Install Programs via Homebrew
#
###################################################################

LINE_BREAK="===================================================================================="
function print_stamp() { echo -e "\n$(date +'%F %T') $@"; }

print_stamp "$0 Started"

brew update

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

# ################### BREW INSTALL #################################

# general tools
brew_install cask htop jq speedtest-cli tldr tree watch wget wifi-password

# development
brew_install black flake8 pipenv pyenv # python
brew_install entr
brew_install postgresql
brew_install go

# Additional system dependencies needed for Python compilation by pyenv (optional, but recommended)
# https://github.com/pyenv/pyenv/wiki
brew_install openssl readline sqlite3 xz zlib

# download youtube - ffmpeg needed for converting to audio files :)
brew_install youtube-dl ffmpeg


# ################### BREW CASK #################################

# general tools
brew_cask_install dropbox firefox google-chrome \
    tunnelblick vlc zoomus

# note taking
brew_cask_install simplenote sublime-merge sublime-text joplin

# development
brew_cask_install iterm2 lepton meld postman visual-studio-code

# mac window management
brew_cask_install rectangle

# logitech
brew_cask_install logitech-options logitech-unifying logitech-control-center


# ################### BREW CUSTOM #################################

brew_custom_install

echo "\n› Running 'brew upgrade' and 'brew cleanup'"
brew upgrade
brew cleanup

print_stamp "$0 Completed"