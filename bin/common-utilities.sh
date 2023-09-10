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


# COLORS
default="\033[39m"
black="\033[30m"
red="\033[0;31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m"
magenta="\033[35m"
cyan="\033[36m"
light_gray="\033[37m"
dark_gray="\033[90m"
light_red="\033[91m"
light_green="\033[92m"
light_yellow="\033[93m"
light_blue="\033[94m"
light_magenta="\033[95m"
light_cyan="\033[96m"
white="\033[97m"


# FUNCTIONS


function convert_seconds_to_min() {
    runtime_seconds=$1
    printf %.2f\\n $(echo $runtime_seconds / 60 | bc -l)
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


# print_info "Parent Directory:'$PARENT_DIR'"
# print_info "Dotfiles Directory:'$DOTFILES_DIR'"

# Github CI
# Inspired by https://github.com/mattorb/dotfiles/blob/master/.github/workflows/install.yml
# https://mattorb.com/ci-your-dotfiles-with-github-actions/

is_ci() {
    # Running inside a GITHUB Action build
    [ ${GITHUB_ACTION} ] && return 0
    
    # # Running inside an Azure DevOps pipeline
    # if [ "$TF_BUILD" == "True" ]; then
    #  return 0
    # fi
    
    return 1
}