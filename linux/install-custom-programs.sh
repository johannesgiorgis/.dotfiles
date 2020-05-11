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

CONFIG_FILE="${dotfilesDirectory}/linux/config-custom-programs"
PROGRAMS_DIR="${dotfilesDirectory}/linux/programs"


main() {
    start=$(date +%s)
    echo "$LINE_BREAK"
    start "$0 Started"

    print_info "› Reading config file '${CONFIG_FILE}'..."
    while read -r line
    do
        # Skip header file
        if [[ "${line}" == "#"* ]]
        then
            continue
        fi

        installer=$"${PROGRAMS_DIR}/$line.sh"
        print_info "› Running installer '${installer}'"
        bash "${installer}"
        success "› Running installer '${installer}'"
        
    done < "${CONFIG_FILE}"

    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
}



main