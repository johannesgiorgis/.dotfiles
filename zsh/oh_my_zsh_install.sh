#!/usr/bin/env bash

###################################################################
#
# Install Oh My ZSH! - https://ohmyz.sh/
# ------------------
#
# Theme: Powerlevel10k
#
# Plugins:
#   - zsh-autosuggestions
#   - zsh-syntax-highlighting
#
###################################################################

echo -e "\nInstalling Oh My ZSH! and plugins..."

main() {
    ensure_fresh_oh_my_zsh_directory
    manual_install_meslo_nerd_font
    install_oh_my_zsh
    install_plugins
}

ensure_fresh_oh_my_zsh_directory() {
    # Ensure directory is removed to ensure fresh installation
    OMZ_DIR="${HOME}/.oh-my-zsh"

    if [ -d "${OMZ_DIR}" ]
    then
        echo -e "\nDirectory '${OMZ_DIR}' exists! Deleting it to ensure fresh installation"
        rm -rf "${OMZ_DIR}"
    else
        echo -e "\nDirectory doesn't exist"
    fi
}

manual_install_meslo_nerd_font() {
    dest="${HOME}/.fonts/"

    regular="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
    bold="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
    italic="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
    italic_bold="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"

    if [ -d "${dest}" ]
    then
        echo "Directory '${dest}' exists"
    else
        echo "Directory '${dest}' doesn't exist. Creating it..."
        mkdir -v "${dest}"
    fi

    wget -P "${dest}" "${regular}"
    wget -P "${dest}" "${bold}"
    wget -P "${dest}" "${italic}"
    wget -P "${dest}" "${italic_bold}"
}

install_oh_my_zsh() {
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_plugins() {
    echo -e "\nInstalling 'powerlevel10k' theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

    echo -e "\nGetting 'zsh-autosuggestions' plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    echo -e "\nGetting 'zsh-syntax-highlighting' plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}

main


echo -e "\nCompleted installing Oh My ZSH! and plugins!"
