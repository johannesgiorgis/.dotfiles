#!/usr/bin/env bash

###################################################################
#
# Create Symlinks
# ---------------
#
# Create Symlinks of dotfiles in home directory
#
###################################################################

# Up from scripts directory
cd ../

dotfiles_dir=$(pwd)

function linkDotfile {
    dest="${HOME}/${1}"
    date_string=$(date "+%Y-%m-%d-%H%M")

    if [ -h ~/${1} ]; then
        # Existing symlink
        echo "Removing existing symlink: ${dest}"
        rm -v "${dest}"
    
    elif [ -f "${dest}" ]; then
        # Existing file
        echo "Backing up existing file: ${dest}"
        mv -v ${dest}{,.${date_string}}
    
    elif [ -d "${dest}" ]; then
        # Existing directory
        echo "Backing up existing directory: ${dest}"
        mv -v ${dest}{,.${date_string}}
    fi

    echo "Creating new symlink: ${dest}"
    ln -sv ${dotfiles_dir}/${1} ${dest}
}

linkDotfile .vimrc
linkDotfile .bashrc
