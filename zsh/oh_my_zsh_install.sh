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

export SUPPORT_DIR="${HOME}/.dotfiles/support"
source "${SUPPORT_DIR}/common_utilities.sh"


main() {
    start=$(date +%s)
    echo "${LINE_BREAK}"
    print_info "Installing Oh My ZSH! and plugins..."

    ensure_fresh_oh_my_zsh_directory

    if test "$(uname)" = "Darwin"
    then
        print_info "You can install Meslo Nerd Font via 'p10k configure' on MacOS"

    elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
    then
        manual_install_meslo_nerd_font
    fi

    install_oh_my_zsh
    install_plugins

    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
}

ensure_fresh_oh_my_zsh_directory() {
    print_info "› Ensuring OMZ directoryis removed to ensure fresh installation"
    OMZ_DIR="${HOME}/.oh-my-zsh"

    print_info "Checking for directory '${OMZ_DIR}'..."
    if [ -d "${OMZ_DIR}" ]
    then
        print_info "› Directory '${OMZ_DIR}' exists! Deleting it to ensure fresh installation"
        rm -rf "${OMZ_DIR}"
    else
        warn "› Directory '${OMZ_DIR}' doesn't exist"
    fi

    success "› Ensuring OMZ directoryis removed to ensure fresh installation"
}

manual_install_meslo_nerd_font() {
    print_info "› Manually installing Meslo Nerd Font..."
    dest="${HOME}/.fonts/"

    base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
    regular="${base_url}/MesloLGS%20NF%20Regular.ttf"
    bold="${base_url}/MesloLGS%20NF%20Bold.ttf"
    italic="${base_url}/MesloLGS%20NF%20Italic.ttf"
    italic_bold="${base_url}/MesloLGS%20NF%20Bold%20Italic.ttf"

    if [ -d "${dest}" ]
    then
        print_info "› Directory '${dest}' exists"
    else
        print_info "› Directory '${dest}' doesn't exist. Creating it..."
        mkdir -v "${dest}"
    fi

    wget -P "${dest}" "${regular}"
    wget -P "${dest}" "${bold}"
    wget -P "${dest}" "${italic}"
    wget -P "${dest}" "${italic_bold}"

    success "› Completed manually installing Meslo Nerd Font!"
}

install_oh_my_zsh() {
    print_info "› Installing Oh My ZSH..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    success "› Completed installing Oh My ZSH!"
}

install_plugins() {
    print_info "› Installing plugins..."

    print_info "› Installing 'powerlevel10k' theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

    print_info "› Getting 'zsh-autosuggestions' plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    print_info "› Getting 'zsh-syntax-highlighting' plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    success "› Completed installing plugins"
}


main