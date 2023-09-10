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

PARENT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"
DOTFILES_DIR="$(cd "$( dirname "$PARENT_DIR" )" && pwd -P)"

export SCRIPT_BREAK LINE_BREAK DOTFILES_DIR

# COLORS
DEFAULT="\033[39m"
BLACK="\033[30m"
RED="\033[0;31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
LIGHT_GRAY="\033[37m"
DARK_GRAY="\033[90m"
LIGHT_RED="\033[91m"
LIGHT_GREEN="\033[92m"
LIGHT_YELLOW="\033[93m"
LIGHT_BLUE="\033[94m"
LIGHT_MAGENTA="\033[95m"
LIGHT_CYAN="\033[96m"
WHITE="\033[97m"

export DEFAULT BLACK RED GREEN YELLOW BLUE MAGENTA CYAN LIGHT_GRAY DARK_GRAY LIGHT_RED \
    LIGHT_GREEN LIGHT_YELLOW LIGHT_BLUE LIGHT_MAGENTA LIGHT_CYAN WHITE



# FUNCTIONS


function convert_seconds_to_min() {
    runtime_seconds=$1
    printf %.2f\\n "$(echo "$runtime_seconds" / 60 | bc -l)"
    # echo %.2f\\n $(echo $runtime_seconds / 60 | bc -l)
}


# >>> OUTPUT DISPLAY FUNCTIONS

function print_stamp() {
    echo -e "\n$(date +'%F %T') $*";
}


function print_info() {
    # printf "$(date +'%F %T')  [ \033[00;34m..\033[0m ] $1\n"
    echo -e "$(date +'%F %T')  [ \033[00;34m..\033[0m ] $1"
}


function user() {
    # printf "$(date +'%F %T')  [ \033[0;33m??\033[0m ] $1\n"
    echo -e "$(date +'%F %T')  [ \033[0;33m??\033[0m ] $1"
}


function success() {
    # printf "\033[2K$(date +'%F %T')  [ \033[00;32mOK\033[0m ] $1\n"
    echo -e "\033[2K$(date +'%F %T')  [ \033[00;32mOK\033[0m ] $1"
}


function fail() {
    # printf "\033[2K$(date +'%F %T')  [\033[0;31mFAIL\033[0m] $1\n"
    echo -e "\033[2K$(date +'%F %T')  [\033[0;31mFAIL\033[0m] $1\n"
    # echo ''
    exit
}


function warn() {
    # printf "\033[2K$(date +'%F %T')  [\033[0;31mWARN\033[0m] $1\n"
    echo -e "\033[2K$(date +'%F %T')  [\033[0;31mWARN\033[0m] $1\n"
    # echo ''
}


function start() {
    # printf "\033[2K$(date +'%F %T')  [\033[0;36mSTART\033[0m] $1\n"
    echo -e "\033[2K$(date +'%F %T')  [\033[0;36mSTART\033[0m] $1\n"
    echo ''
}


function finished() {
    # printf "\033[2K$(date +'%F %T')  [\033[0;36mDONE\033[0m] $1\n"
    echo -e "\033[2K$(date +'%F %T')  [\033[0;36mDONE\033[0m] $1\n"
    # echo ''
}

# <<< OUTPUT DISPLAY FUNCTIONS


# print_info "Parent Directory:'$PARENT_DIR'"
# print_info "Dotfiles Directory:'$DOTFILES_DIR'"

# Github CI
# Inspired by https://github.com/mattorb/dotfiles/blob/master/.github/workflows/install.yml
# https://mattorb.com/ci-your-dotfiles-with-github-actions/

is_ci() {
    # Running inside a GITHUB Action build
    [ "${GITHUB_ACTION}" ] && return 0
    
    # # Running inside an Azure DevOps pipeline
    # if [ "$TF_BUILD" == "True" ]; then
    #  return 0
    # fi
    
    return 1
}