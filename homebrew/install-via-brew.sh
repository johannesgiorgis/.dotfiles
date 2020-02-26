
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
    
    print_stamp "Completed installing via custom brew!"
}

# Basics
brew_install cask pipenv pyenv openssl \
    readline sqlite3 xz zlib tree entr \
    black flake8 htop wget watch \
    wifi-password tldr youtube-dl speedtest-cli \
    jq postgresql

# Brew Cask
brew_cask_install google-chrome iterm2 lepton \
    sublime-text dropbox meld tunnelblick rectangle \
    postman simplenote firefox joplin

# Brew Custom
brew_custom_install

echo "Running 'brew upgrade' and 'brew cleanup'"
brew upgrade
brew cleanup

print_stamp "$0 Completed"