#!/usr/bin/env bash

# Post Installation Check

kernel_name=$(uname -s)

echo "kernel_name:$kernel_name"

if [ "$kernel_name" == "Darwin" ]; then
    brew list --versions
    brew list --cask --versions

elif [ "$kernel_name" == "Linux" ]; then
    echo "TODO: Figure out what to check for Linux"
fi
