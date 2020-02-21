
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
    print_stamp "Installing: ${@}..."
    brew install "${@}"
	print_stamp "Completed installing ${@}!"
}

function brew_cask_install {
    print_stamp "Installing: ${@}..."
    brew cask install "${@}"
	print_stamp "Completed installing ${@}!"
}

# Basics
brew_install cask pipenv pyenv openssl \
    readline sqlite3 xz zlib tree entr \
    black flake8 htop wget watch \
    wifi-password tldr youtube-dl speedtest-cli

# Brew Cask
brew_cask_install google-chrome iterm2 lepton sublime-text dropbox meld

brew upgrade
brew cleanup

print_stamp "$0 Completed"