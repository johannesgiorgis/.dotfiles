#!/usr/bin/env bash

###################################################################
#
# Bootstrap Script
# ----------------
# Runs installation scripts
# Symlink dot files
#
###################################################################

set -e

export SUPPORT_DIR="${HOME}/.dotfiles/support"
source "${SUPPORT_DIR}/common-utilities.sh"


main() {
    start=$(date +%s)
    echo "${SCRIPT_BREAK}"
    print_info "$0 Started"

    cd "$(dirname "$0")/.."
    DOTFILES_ROOT=$(pwd -P)

    # setup_gitconfig
    make_sh_files_executable
    remove_all_linked_dotfiles
    source_dot
    clean_dotfiles_install
    install_dotfiles
    link_bin_directory
    set_zsh_shell_as_default

    end=$(date +%s)
    runtime=$((end-start))
    runtime_min=$(convert_seconds_to_min $runtime)

    finished "$0 Completed with $runtime seconds ($runtime_min mins)"
    echo "${SCRIPT_BREAK}"
}


# Helper Functions

function remove_all_linked_dotfiles() {
    print_info '› Removing all linked dotfiles...'
    find_dotfiles | \
        xargs -n1 basename | \
        sed 's/.symlink//' | \
        sed -e "s|^|$HOME/.|" | \
        xargs rm -fv
    success '› Completed removing all linked dotfiles!'
}


function source_dot() {
    print_info '› Sourcing bin/dot...'
    source bin/dot
    success '› Completed sourcing bin/dot!'
}


function clean_dotfiles_install() {
    print_info '› Removing ~/.zshrc file and installing dot files...'
    # Oh My Zsh always installs a default ~/.zshrc file
    # Let's remove it to ensure clean setup
    if [[ -f ~/.zshrc ]]
    then
        rm -v ~/.zshrc
    else
        warn "› No ~/.zshrc file found!"
    fi

    install_dotfiles
    success '› Completed removing ~/.zshrc file and installing dot files!'
}


function setup_gitconfig() {
    if ! [ -f git/gitconfig.local.symlink ]
    then
        print_info '› setup gitconfig'

        git_credential='cache'
        if [ "$(uname -s)" == "Darwin" ]
        then
            git_credential='osxkeychain'
        fi

        user ' - What is your github author name?'
        read -e git_authorname
        user ' - What is your github author email?'
        read -e git_authoremail

        sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" git/gitconfig.local.symlink.example > git/gitconfig.local.symlink

        success '› gitconfig'
    fi
}


function link_file() {
    local src=$1 dst=$2

    local overwrite= backup= skip=
    local action=

    # if dst exists and is a symlink
    if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
    then

        if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
        then

            local currentSrc="$(readlink $dst)"

            if [ "$currentSrc" == "$src" ]
            then

                skip=true;

            else

                user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
                [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
                read -n 1 action

                case "$action" in
                    o )
                        overwrite=true;;
                    O )
                        overwrite_all=true;;
                    b )
                        backup=true;;
                    B )
                        backup_all=true;;
                    s )
                        skip=true;;
                    S )
                        skip_all=true;;
                    * )
                        ;;
                esac

            fi

        fi

        overwrite=${overwrite:-$overwrite_all}
        backup=${backup:-$backup_all}
        skip=${skip:-$skip_all}

        if [ "$overwrite" == "true" ]
        then
            rm -rf "$dst"
            success "removed $dst"
        fi

        if [ "$backup" == "true" ]
        then
            mv "$dst" "${dst}.backup"
            success "moved $dst to ${dst}.backup"
        fi

        if [ "$skip" == "true" ]
        then
            success "skipped $src"
        fi
    fi

    if [ "$skip" != "true" ]  # "false" or empty
    then
        ln -s "$1" "$2"
        success "linked $1 to $2"
    fi
}


function find_dotfiles() {
    find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*'
}


function install_dotfiles() {
    print_info '› Installing dotfiles'

    local overwrite_all=false backup_all=false skip_all=false

    for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
    do
        dst="$HOME/.$(basename "${src%.*}")"
        print_info "› Linking '$src' to '$dst'"
        link_file "$src" "$dst"

        if [[ "${src}" == *"vim"* ]]
        then
            warn "› \tRUN: sudo ln -s \"$src\" \"/root/.vimrc\""
        fi
    done

    success '› Completed installing dotfiles'
}


function link_bin_directory() {
    print_info "Linking bin directory"

    local overwrite_all=false backup_all=false skip_all=false
    
    destination="$HOME/.bin"
    source="$DOTFILES_ROOT/bin"

    print_info "› Linking '$source' to '$destination'"
    link_file "$source" "$destination"
    
    success "Completed linking bin directory"
}


function make_sh_files_executable() {
	print_info '› Making *.sh files executable'

	find . -name '*.sh' | xargs chmod +x

	success '› Completed making *.sh files executable'
}


function set_zsh_shell_as_default() {
    # Checks if zsh is the default shell
    # If it is, returns
    # It it isn't, it makes it the default shell
    print_info "› changing default shell to zsh"

    if [[ "${SHELL}" == *"zsh"* ]]
    then
        success "› Default shell is already zsh :)"
        return
    fi

    if test "$(uname)" = "Darwin"
    then
        print_info "› setting zsh as default for mac..."
        sudo chsh -s $(which zsh)
        success "› Completed setting zsh as default for mac"

    elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
    then
        print_info "› setting zsh as default for linux..."
        chsh -s $(which zsh)
        success "› Completed setting zsh as default for linux"
    fi
    success "› Completed changing default shell to zsh"
}



main