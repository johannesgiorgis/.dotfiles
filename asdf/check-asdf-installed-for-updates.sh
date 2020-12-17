
#!/usr/bin/env bash

###################################################################
#
# Check whether installed asdf plugin versions need to be updated
#
###################################################################

export SUPPORT_DIR="${HOME}/.dotfiles/support"
source "${SUPPORT_DIR}/common-utilities.sh"

CONFIG_FILE="${dotfilesDirectory}/asdf/config-asdf"

main() {
    start=$(date +%s)
    echo "$LINE_BREAK"
    start "$0 Started"

    export STATUS=""
    export UPDATE_COMMANDS=""

    installed_plugins=$(asdf list | grep "^[a-zA-Z]" | tr '\n' ' ')

    for plugin in $(echo $installed_plugins)
    do
        print_info "› Checking updates for $plugin..."
        installed_versions=$(asdf list "$plugin" | sed 's/ //g')

        for installed_version in $(echo $installed_versions)
        do
            print_info "› Checking for $plugin $installed_version..."
            STATUS="${STATUS}${plugin}"
            # UPDATE_COMMANDS="${UPDATE_COMMANDS}${plugin}"
        
            subversion_root=$(echo "$installed_version" | sed 's/[0-9]*$//')
            # echo "subversion_root:$subversion_root"
            version_root=$(echo "$installed_version" | grep -o '^\w\+')
            # echo "version_root:$version_root"
        
            plugin_all_versions=$(asdf list-all "$plugin")
            latest_version_root=$(echo "$plugin_all_versions" | grep "^$version_root" | tail -1)
            latest_subversion_root=$(echo "$plugin_all_versions" | grep "^$subversion_root" | tail -1)
            file_version=$(grep "$plugin" "$CONFIG_FILE" | grep "$latest_subversion_root" | awk -F' ' '{print $3}')

            print_info "› Current vs File vs Subversion vs Version:'$installed_version' vs '$file_version' vs '$latest_subversion_root' vs '$latest_version_root'"
        
            # Check against latest sub-version
            compare_subversions "$installed_version" "$latest_subversion_root"

            # Check against latest version - ignore dev, rc
            if [[ "$latest_version_root" == *"dev"* ]] \
                || [[ "$latest_version_root" == *"rc"* ]]
            then
                success "› no need to update due to rc/dev version - $plugin $latest_version_root"
                STATUS="${STATUS}|version:new rc/dev version\n"
                continue
            fi
            compare_versions "$installed_version" "$latest_version_root"
        done
    done

    STATUS="${STATUS}\n"
    UPDATE_COMMANDS="${UPDATE_COMMANDS}\n"

    echo ''
    print_info "› Show 'asdf current' output:"
    asdf current

    echo ''
    print_info "› asdf installed software status:"
    echo -e "$STATUS"

    print_info "› asdf update software command:"
    echo -e "$UPDATE_COMMANDS"

    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
}


# ################### HELPER FUNCTIONS #################################

function compare_subversions() {
    local installed_version=$1
    local latest_subversion=$2
    if [[ "$installed_version" == "$latest_subversion_root" ]]
    then
        success "No need to update $plugin $installed_version!"
        STATUS="${STATUS}|subversion:$installed_version good"
    else
        warn "NEED TO UPDATE $plugin $installed_version to $latest_subversion_root"
        STATUS="${STATUS}|subversion:$installed_version -> $latest_subversion_root"
        # echo "Commands:"
        command="asdf install $plugin $latest_subversion_root && asdf uninstall $plugin $installed_version && asdf reshim $plugin $latest_subversion_root && asdf global $plugin $latest_subversion_root"
        # echo "$command"
        UPDATE_COMMANDS="${UPDATE_COMMANDS}${plugin} subversion|${command}\n"
    fi
}


function compare_versions() {
    local installed_version=$1
    local latest_version_root=$2
    if [[ "$installed_version" == "$latest_version_root" ]]
    then
        success "No need to update $plugin $installed_version!"
        STATUS="${STATUS}|version:$installed_version good\n"
    else
        warn "MAYBE NEED TO UPDATE $plugin $installed_version to $latest_version_root?"
        STATUS="${STATUS}|version:$installed_version -> $latest_version_root?\n"
        # echo "Commands:"
        command="asdf install $plugin $latest_version_root && asdf uninstall $plugin $installed_version && asdf reshim $plugin $latest_version_root && asdf global $plugin $latest_version_root"
        # echo "$command"
        UPDATE_COMMANDS="${UPDATE_COMMANDS}${plugin} version|${command}\n"
    fi
}

main
