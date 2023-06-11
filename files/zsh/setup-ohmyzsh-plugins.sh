#!/usr/bin/env bash

set -e

# Grab ohmyzsh plugins for ease of use :)
# https://terminalroot.com/how-to-clone-only-a-subdirectory-with-git-or-svn/

mkdir -p ohmyzsh && cd ohmyzsh

pwd

remote_url=$(git remote -v | head -1 | awk -F' ' '{print $2}')
echo "Remote URL:$remote_url"


if [[ $remote_url == *"ohmyzsh/ohmyzsh"* ]]
then
    echo "Git remote url already set. Skipping git init process"

else

    git init

    git remote add -f origin https://github.com/ohmyzsh/ohmyzsh

    git config core.sparseCheckout true

    echo 'plugins/' >> .git/info/sparse-checkout
fi

echo "Fetching latest..."
git pull origin master
