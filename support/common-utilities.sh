#!/usr/bin/env bash

###################################################################
#
# Common Utilities
# ----------------
#
# Common Utilities other functions can re-use
#
###################################################################


# VARIABLES

SCRIPT_BREAK="========================================================================================================================================="
LINE_BREAK="------------------------------------------------------------------------------------------------------------"

parentDirectory="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"
dotfilesDirectory="$(cd "$( dirname "$parentDirectory" )" && pwd -P)"


# FUNCTIONS


function convert_seconds_to_min() {
    runtime_seconds=$1
    printf %.2f\\n $(echo $runtime_seconds / 60 | bc -l)
}

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# >>> OUTPUT DISPLAY FUNCTIONS

function print_stamp() {
    echo -e "\n$(date +'%F %T') $@";
}


function print_info() {
    printf "$(date +'%F %T')  [ \033[00;34m..\033[0m ] $1\n"
}


function user() {
    printf "$(date +'%F %T')  [ \033[0;33m??\033[0m ] $1\n"
}


function success() {
    printf "\033[2K$(date +'%F %T')  [ \033[00;32mOK\033[0m ] $1\n"
}


function fail() {
    printf "\033[2K$(date +'%F %T')  [\033[0;31mFAIL\033[0m] $1\n"
    echo ''
    exit
}


function warn() {
    printf "\033[2K$(date +'%F %T')  [\033[0;31mWARN\033[0m] $1\n"
    echo ''
}


function start() {
    printf "\033[2K$(date +'%F %T')  [\033[0;36mSTART\033[0m] $1\n"
    echo ''
}


function finished() {
    printf "\033[2K$(date +'%F %T')  [\033[0;36mDONE\033[0m] $1\n"
    echo ''
}

# <<< OUTPUT DISPLAY FUNCTIONS


print_info "Parent Directory:'$parentDirectory'"
print_info "Dotfiles Directory:'$dotfilesDirectory'"