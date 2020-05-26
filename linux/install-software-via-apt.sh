#!/usr/bin/env bash

###################################################################
#
# Install Software via Apt
# ------------------------
#
###################################################################

export SUPPORT_DIR="${HOME}/.dotfiles/support"
source "${SUPPORT_DIR}/common-utilities.sh"

CONFIG_FILE="${dotfilesDirectory}/linux/config-apt"


main() {
    start=$(date +%s)
	echo "$LINE_BREAK"
	start "$0 Started"

    apt_update

    num_installed=0
    num_already_installed=0
    num_packages=0
    total_packages=$(cat "${CONFIG_FILE}" | egrep -v '#|^$' | wc -l)

    print_info "› Reading config file '${CONFIG_FILE}'..."
    while read -r line
    do
        # Skip header and empty lines
        if [[ "${line}" == "#"* ]] || [[ "${line}" == "" ]]
        then
            continue
        fi

        num_packages=$((num_packages + 1))
        status="${num_packages}/${total_packages}"

        package=$(echo "${line}" | cut -d ' ' -f1)

        if which "${package}" &> /dev/null || dpkg -s "${package}" &> /dev/null
        then
            print_info "› $status - Package '${package}' is already installed"
            num_already_installed=$((num_already_installed + 1))
            continue
        fi

        print_info "› $status - Installing package '${package}'..."
        apt_install "${package}"
        num_installed=$((num_installed + 1))

    done < "${CONFIG_FILE}"

    sudo apt-get upgrade --yes
    
    report="Newly Installed:${num_installed}"
    report="${report}|Already Installed:${num_already_installed}"
    report="${report}|Total:${num_packages}"
    print_info "${report}"

    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
}


# ################### APT UTILITIES #################################

function apt_update() {
    print_info "› Running 'apt-get update'..."
    sudo apt-get update
    success "› Completed running 'apt-get update'!"
}

function apt_install() {
	which $@ &> /dev/null

    if [ $? -eq 0 ]
    then
		print_info "› Already installed: ${@}"
        return
	fi

    print_info "› Installing: ${@}..."
    sudo apt-get install --yes "${@}"
    result=$?
    print_info "› result:'$result'"

    if [ $result -ne 0 ]
    then
        warn "Package '${@}' was not installed"
        return
    fi
    success "› Completed installing ${@}!"
}



main