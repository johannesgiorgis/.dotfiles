#!/usr/bin/env bash

###################################################################
#
# Install Custom Programs
# -----------------------
#
# Install custom 3rd party software
# through additional packages
#
###################################################################

export SUPPORT_DIR="${HOME}/.dotfiles/support"
source "${SUPPORT_DIR}/common-utilities.sh"


main() {
    start=$(date +%s)
    echo "$LINE_BREAK"
    start "$0 Started"

    export PROGRAMS_DIR="${HOME}/.dotfiles/linux/programs"

    cd "${PROGRAMS_DIR}"

    for f in $(ls *.sh | egrep -v 'serverless|flux|pgadmin')
    do
        base_name=${f%%.*}
        print_info "Installing '$base_name'..."
        bash $f
        success "Completed installing '$base_name'!"
    done

    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
}



main