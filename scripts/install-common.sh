#!/usr/bin/env bash

###################################################################
#
# Install Common
# --------------
# Run all dotfiles installers that end with 'install.sh'
#
###################################################################

set -e

export SUPPORT_DIR="${HOME}/.dotfiles/support"
source "${SUPPORT_DIR}/common-utilities.sh"

main() {
    start=$(date +%s)
    start "$0 started"

    cd "$(dirname $0)"/..

    # find the installers and run them iteratively
    print_info "Finding all files ending with 'install.sh'..."
    find . -name "*install.sh" | install_all_common

    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
}


function install_all_common() {
    while read installer
    do
        print_info "Installer:${installer}"
        bash "${installer}"
        success "${installer}"
    done
}



main