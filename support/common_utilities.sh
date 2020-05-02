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
LINE_BREAK="===================================================================================="

# FUNCTIONS

function print_stamp() { echo -e "\n$(date +'%F %T') $@"; }

print_info () {
  printf "\r$(date +'%F %T')  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r$(date +'%F %T')  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K$(date +'%F %T')  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K$(date +'%F %T')  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

warn () {
  printf "\r\033[2K$(date +'%F %T')  [\033[0;31mWARN\033[0m] $1\n"
  echo ''
  exit
}

finished () {
  printf "\r\033[2K$(date +'%F %T')  [\033[0;36mDONE\033[0m] $1\n"
  echo ''
}

convert_seconds_to_min () {
    runtime_seconds=$1
    printf %.2f\\n $(echo $runtime_seconds / 60 | bc -l)
}