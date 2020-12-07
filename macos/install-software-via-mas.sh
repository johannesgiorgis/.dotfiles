#!/usr/bin/env bash

###################################################################
#
# Install Programs via Mac App Store
#
###################################################################

export SUPPORT_DIR="${HOME}/.dotfiles/support"
source "${SUPPORT_DIR}/common-utilities.sh"


main() {
    start=$(date +%s)
    echo "${LINE_BREAK}"
    print_info "$0 Started"

    # mas install
    install_general_tools

    mas_upgrade
    
    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
}


# ################### MAS UTILITIES #################################

function mas_install() {
    print_info "› Installing via mas: '${@}'..."
    mas install "${@}"
	success "› Completed installing via mas: '${@}'!"
}


function mas_upgrade() {
    print_info "› Running 'mas upgrade'"
    mas upgrade
    success "› Completed running 'mas upgrade'!"
}


# ################### MAS INSTALL #################################

function install_general_tools() {
    # Display Menu (2.2.3)
    mas_install 549083868

    # CopyClip (1.9.3)
    mas_install 595191960

    # Microsoft Remote Desktop (10.3.12)
    mas_install 1295203466

    # Xcode (11.5)
    mas_install 497799835

    # Lightshot Screenshot (2.22)
    mas_install 526298438
}

main