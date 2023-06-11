#!/usr/bin/env bash

###################################################################
#
# Check whether software installed directly from github need 
# to be updated
#
###################################################################

source "${HOME}/.dotfiles/bin/common-utilities.sh"

CONFIG_FILE="${DOTFILES_DIR}/ansible/group_vars/all/github.yml"
GITHUB_API_URL="https://api.github.com/repos"

main() {
    start=$(date +%s)
    echo "$LINE_BREAK"
    start "$0 Started"

    export STATUS=""
    export UPDATE_COMMANDS=""

    # curl -u "johannesgiorgis" https://api.github.com

    installed_projects=$(grep "project" "$CONFIG_FILE" | sed 's/ //g' | tr '\n' ' ')
    # echo -e "INSTALLED_PROJECTS\n${installed_projects}"
    installed_versions=$(grep "version" "$CONFIG_FILE" | sed 's/ //g')
    # echo -e "INSTALLED_VERSIONS:\n$installed_versions"

    for installed_project in $installed_projects
    do
        print_info "› Checking updates for $installed_project..."

        name=$(echo "$installed_project" | cut -d':' -f1 | sed 's/ //g' | cut -d'_' -f1)
        # echo "NAME:$name"

        project=$(echo "$installed_project" | cut -d':' -f2 | sed 's/ //g')
        github_url="${GITHUB_API_URL}/$project/releases/latest"
        #echo "$github_url"

        latest_tag=$(curl -s "$github_url" | grep "tag_name" | cut -d':' -f2 | sed 's/ //g;s/,//g;s/"//g;s/v//g')
        #echo "Latest tag:$latest_tag"
        installed_version=$(echo "$installed_versions" | grep "$name" | cut -d':' -f2)
        #echo "installed_version:$installed_version"

        compare_versions "$installed_version" "$latest_tag"
        # break
    done


    STATUS="${STATUS}\n"
    UPDATE_COMMANDS="${UPDATE_COMMANDS}\n"

    echo ''
    print_info "› github installed software status:"
    echo -e "$STATUS"

    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${LINE_BREAK}"
    exit 0
}

# ################### HELPER FUNCTIONS #################################


function compare_versions() {
    local installed_version=$1
    local latest_version=$2
    # echo "VS:$installed_version vs. $latest_version"
    if [[ "$installed_version" == "$latest_version" ]]
    then
        success "No need to update $name $installed_version!"
        STATUS="${STATUS}\033[00;32m${name}|version:$installed_version good\033[0m\n"
    else
        warn "MAYBE NEED TO UPDATE $name $installed_version to $latest_version?"
        STATUS="${STATUS}\033[0;31m${name}|version:$installed_version -> $latest_version? \033[0m\n"
    fi
}

main "$@"
