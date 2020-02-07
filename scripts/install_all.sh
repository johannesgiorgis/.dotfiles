#!/usr/bin/env bash

###################################################################
#
# Run all dotfiles installers.
#
###################################################################

set -e

cd "$(dirname $0)"/..

# find the installers and run them iteratively
find . -name *install.sh | while read installer ; do echo "Installer:${installer}"; bash "${installer}" ; done