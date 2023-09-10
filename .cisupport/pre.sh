#!/usr/bin/env bash

# Pre Installation Check

kernel_name=$(uname -s)

echo "kernel_name:$kernel_name"

if [ "$kernel_name" == "Darwin" ]; then
    brew --version
    sw_vers

elif [ "$kernel_name" == "Linux" ]; then
    # https://kinsta.com/knowledgebase/check-ubuntu-version/
    cat /etc/issue
    hostnamectl
fi

curl --version
