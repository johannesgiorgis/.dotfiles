#!/usr/bin/env bash

###################################################################
#
# Check whether installed asdf plugin versions need to be updated
# Easier to write in another language - python, go
#
###################################################################

source "${HOME}/.dotfiles/bin/common-utilities.sh"

CONFIG_FILE="${DOTFILES_DIR}/group_vars/all/asdf.yml"
INFRA_ROLES="${DOTFILES_DIR}/roles/infrastructure"


main() {
    start=$(date +%s)
    echo "$LINE_BREAK"
    start "$0 Started"

    export STATUS=""
    export UPDATE_SUBVERSIONS=""
    export UPDATE_VERSIONS=""

    asdf_list=$(asdf list)

    STATUS="PLUGIN|VERSION|SUBVERSION\n"

    for plugin in $(echo "$asdf_list" | grep "^[a-zA-Z]")
    # for plugin in "golang"
    do
        print_info "${blue}› Checking updates for ${plugin}...${default}"
        plugin_task_file="${INFRA_ROLES}/${plugin}/tasks/main.yml"
        # echo $plugin_task_file
        latest_version=$(asdf latest "$plugin")
        plugin_all_versions=$(asdf list-all "$plugin")
        installed_versions=$(echo "$asdf_list" |\
            rg -U "${plugin}(\n( +.+))*" |
            grep -v "$plugin" |\
            sed 's/ //g')

        for installed_version in $(echo $installed_versions)
        do
            print_info "› Checking for ${cyan}$plugin $installed_version...${default}"
            STATUS="${STATUS}${plugin}"
        
            # FIXME: Logic can't handle when installed_version is 1.18
            # It returns the '1.' which isn't what we want
            # For now will ensure golang 1.18.x is installed instead of 1.18
            subversion_root=$(echo "$installed_version" | sed 's/[0-9]*$//')
            print_info "subversion_root:$subversion_root"
            version_root=$(echo "$installed_version" | grep -o '^\w\+')
            print_info "version_root:$version_root"
        
            latest_version_root=$(echo "$plugin_all_versions" |\
                grep "^$version_root" | tail -1)
            latest_subversion_root=$(echo "$plugin_all_versions" |\
                grep "^$subversion_root" | tail -1)
            file_version=$(rg -U "${plugin}_versions:(\n( +-.+))*" "$plugin_task_file" |\
                rg "$subversion_root" |\
                sed 's/ //g; s/-//g')

            print_info "› Current vs File vs Subversion vs Version vs Latest:"
            print_info "'$installed_version' vs '$file_version' vs '$latest_subversion_root' vs '$latest_version_root' vs $latest_version"

            if [[ "$file_version" == "" ]]; then
                warn "${light_red}$plugin $installed_version no longer in file!${default}"
            fi

            
            # Check against latest version - ignore dev, rc, beta
            if [[ "$latest_version_root" == *"dev"* ]] \
                || [[ "$latest_version_root" == *"rc"* ]] \
                    || [[ "$latest_version_root" == *"beta"* ]] \
                        || [[ "$latest_version_root" == *"alpha"* ]]
            then
                # 2022-12 Update: Check against latest version of plugin via asdf latest <plugin>
                compare_versions "$installed_version" "$latest_version"
                # success "› no need to update due to rc/dev/beta version - $plugin $latest_version_root"
                # STATUS="${STATUS}|version:new rc/dev version\n"
                # continue
            else
                compare_versions "$installed_version" "$latest_version_root"
            fi

            # Check against latest sub-version
            compare_subversions "$installed_version" "$latest_subversion_root"

        done
    done

    STATUS="${STATUS}\n"
    STATUS_SUBVERSION="${STATUS_SUBVERSION}\n"
    UPDATE_SUBVERSIONS="${UPDATE_SUBVERSIONS}\n"
    UPDATE_VERSIONS="${UPDATE_VERSIONS}\n"

    echo ''
    print_info "${light_blue}› Show 'asdf current' output:"
    echo -e "$(asdf current)${default}\n"

    print_info "${light_yellow}› asdf installed software version status:${default}"
    echo -e "$STATUS" | column -s '|' -t
    echo -e ""

    print_info "${green}› asdf update software command for versions:"
    echo -e "$UPDATE_VERSIONS"
    echo -e "${default}"

    print_info "${light_green}› asdf update software command for subversions:"
    echo -e "$UPDATE_SUBVERSIONS"
    echo -e "${default}"

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
        STATUS="${STATUS}|$installed_version good\n"
    else
        warn "${red}NEED TO UPDATE $plugin $installed_version to $latest_subversion_root${default}"
        STATUS="${STATUS}|$installed_version -> $latest_subversion_root\n"
        command="asdf install $plugin $latest_subversion_root && asdf uninstall $plugin $installed_version && asdf reshim $plugin $latest_subversion_root && asdf global $plugin $latest_subversion_root"
        UPDATE_SUBVERSIONS="${UPDATE_SUBVERSIONS}${command}\n"
    fi
}


function compare_versions() {
    local installed_version=$1
    local latest_version_root=$2
    if [[ "$installed_version" == "$latest_version_root" ]]
    then
        success "No need to update $plugin $installed_version!"
        STATUS="${STATUS}|${green}$installed_version good${default}"
    else
        warn "MAYBE NEED TO UPDATE $plugin $installed_version to $latest_version_root?"
        # STATUS="${STATUS}|${red}$installed_version -> $latest_version_root?${default}"
        STATUS="${STATUS}|$installed_version -> $latest_version_root?"
        command="asdf install $plugin $latest_version_root && asdf uninstall $plugin $installed_version && asdf reshim $plugin $latest_version_root && asdf global $plugin $latest_version_root"
        UPDATE_VERSIONS="${UPDATE_VERSIONS}${command}\n"
    fi
}

main
