#!/usr/bin/env bash

###################################################################
#
# Install Custom Programs for Mac OS
# ----------------------------------
#
# Install custom 3rd party software
# through additional packages
# These programs are either not available on Homebrew
# or its better to install them outside of Homebrew
#
###################################################################

LINE_BREAK="===================================================================================="
function print_stamp() { echo -e "\n$(date +'%F %T') $@"; }


echo "$LINE_BREAK"
print_stamp "$0 Started"

export PROGRAMS_DIR="${HOME}/.dotfiles/macos/programs"

# echo "CURRENT DIR:"
# pwd
# cd programs/
cd "${PROGRAMS_DIR}"


for f in $(ls *.sh)
do
    base_name=${f%%.*}
    print_stamp "Installing '$base_name'..."
    bash $f
    print_stamp "Completed installing '$base_name'!"
done

# print_stamp "Installing F.Lux..."
# ./flux.sh
# print_stamp "Completed installing F.Lux!"


# print_stamp "Installing PGAdmin 4..."
# ./pgadmin.sh
# print_stamp "Completed installing PGAdmin 4!"


# print_stamp "Installing NodeJS and NPM..."
# ./nodejs.sh
# print_stamp "Completed installing NodeJS and NPM!"


# print_stamp "Installing Serverless Framework..."
# ./serverless.sh
# print_stamp "Completed installing Serverless Framework!"


# print_stamp "Installing Miniconda..."
# ./miniconda.sh
# print_stamp "Completed installing Miniconda!"

print_stamp "$0 Completed"
echo "$LINE_BREAK"