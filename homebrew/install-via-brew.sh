
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

# Basics
brew_install black cask entr flake8 htop jq openssl \
    pipenv postgresql pyenv readline speedtest-cli \
    sqlite3 tldr tree watch wget wifi-password \
    xz youtube-dl zlib

# Brew Cask
brew_cask_install dropbox firefox google-chrome \
    iterm2 joplin lepton logitech-options \
    logitech-unifying logitech-control-center \
    meld postman rectangle simplenote sublime-merge \
    sublime-text tunnelblick vlc

# Brew Custom
brew_custom_install

echo "\n› Running 'brew upgrade' and 'brew cleanup'"
brew upgrade
brew cleanup

print_stamp "$0 Completed"