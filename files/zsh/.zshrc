
# source: https://lildude.co.uk/speeding-up-my-zsh-shell
[ -z "$ZPROF" ] || zmodload zsh/zprof

# DEBUG
GITSTATUS_LOG_LEVEL=DEBUG

# alias set-dns="sudo sed -i.old 's/# macOS Notice/nameserver 8.8.8.8/' /var/run/resolv.conf; dscacheutil -flushcache"
# SBR_AUTO_INIT=true

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# M1 - assume brew installed
if [[ $(uname -p) == "arm" ]]
then
    # ensure homebrew packages are recognized before system built in
    # e.g. brew git vs. osx git
    export PATH="/opt/homebrew/bin:$PATH"
fi

# add a function path
# fpath=("$ZSH/functions" "$ZSH/completions" $fpath)
fpath+=~/.zfunc

# Command Auto Completion
# autoload -Uz compinit
autoload -Uz compaudit compinit zrecompile
autoload -U +X bashcompinit && bashcompinit
compinit

ZSH_THEME="powerlevel10k"

if [[ -n "$ZSH_THEME" ]]; then
    source "$ZDOTDIR/themes/$ZSH_THEME/$ZSH_THEME.zsh-theme"
fi

# Set ZSH_CACHE_DIR to the path where cache files should be created
# or else we will use the default cache/
if [[ -z "$ZSH_CACHE_DIR" ]]; then
  ZSH_CACHE_DIR="$ZDOTDIR/cache"
fi


# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# +---------+
# | HISTORY |
# +---------+

## History command configuration
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt INC_APPEND_HISTORY        # Ensure commands are added to the history immediately
setopt HIST_IGNORE_DUPS       # ignore duplicated commands history list
setopt HIST_VERIFY            # show command with history expansion to user before running it

plugins=(
    git
    brew
    docker
    docker-compose
    virtualenv
    golang
    asdf
    # ansible
    command-not-found
    history
    #pipenv
    fd
    #fzf
    npm
    node
    pip
    python
    ripgrep
    rsync
    rust
    terraform
    web-search
    yarn
    zsh-interactive-cd
    zsh-autosuggestions
    zsh-syntax-highlighting
    #taskwarrior
    #timewarrior
)


# Load all stock functions (from $fpath files) called below.


is_plugin() {
  local base_dir=$1
  local name=$2
  builtin test -f $base_dir/plugins/$name/$name.plugin.zsh \
    || builtin test -f $base_dir/plugins/$name/_$name
}

# Add all defined plugins to fpath. This must be done
# before running compinit.
OMZ_DIR="$ZDOTDIR/ohmyzsh"

for plugin in $plugins
do
    if is_plugin "$ZDOTDIR" "$plugin"; then
        fpath=("$ZDOTDIR/plugins/$plugin" $fpath)
    elif is_plugin "$OMZ_DIR" "$plugin"; then
        fpath=("$OMZ_DIR/plugins/$plugin" $fpath)
    else
        echo "[zsh] plugin '$plugin' not found"
    fi
done

# Load all of the plugins that were defined in ~/.zshrc
for plugin in $plugins
do
    if [[ -f "$ZDOTDIR/plugins/$plugin/$plugin.plugin.zsh" ]]; then
        source "$ZDOTDIR/plugins/$plugin/$plugin.plugin.zsh"
    elif [[ -f "$OMZ_DIR/plugins/$plugin/$plugin.plugin.zsh" ]]; then
        source "$OMZ_DIR/plugins/$plugin/$plugin.plugin.zsh"
    fi
done


# User configuration

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# export EDITOR=/usr/bin/vim
# export VISUAL=/usr/bin/vim

# kernel name
kernel_name="$(uname -s)"

###############################################################################################
# >>> ##################################### ALIAS

alias md='mkdir -p'
alias rd=rmdir

alias history='history -i'

if command -v eza 1>/dev/null 2>&1; then
    # source: https://github.com/DarrinTisdale/zsh-aliases-exa
    # general use
    alias ls='eza'                                                         # ls
    alias l='eza -lbF --git'                                               # list, size, type, git
    alias lt='ls -laaF -snew'                                              # list new files last
    alias ll='eza -lbGF --git'                                             # long list
    alias llm='eza -lbGF --git --sort=modified'                            # long list, modified date sort
    alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
    alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list

    # speciality views
    alias lS='eza -1'			                                           # one column, just names
    alias lta='eza --tree --level=2'                                       # tree

else
    # Default for ls
    # alias ls='lsG' # directory color (dark blue) too dark on iterm2 # TODO: Tweak ls colors
    alias lt='ls -lahtFr'
    alias lsa='ls -lah'
    alias l='ls -lah'
    alias ll='ls -lh'
    alias la='ls -lAh'
fi

# docker
alias dka='docker ps -aq | xargs -I{} docker kill {}'		# kill all running docker containers
alias dra='docker ps -aq | xargs -I{} docker rm {}'			# remove all docker containers
alias dpa="echo 'pruning system...' && docker system prune -f && echo 'pruning volumes...' && docker volume prune -f"

alias tailf='tail -f'
alias tt='timetrap'
alias c='code'
alias co='codium'
alias ag='alias | rg'
alias wh='which'

# count files
alias count='find . -type f | wc -l'

# add a copy progress bar
alias cpv='rsync -ah --info=progress2'

# protect yourself from file removal accidents
alias tcn='mv --force -t ~/.local/share/Trash '

# navigate to top leve of a git project
alias cg='cd `git rev-parse --show-toplevel`'
alias gil="git log --pretty=format:'%H' -n 1 | pbcopy"

# python virtual environment management
alias va='source .venv/bin/activate'

# Control output of less
if command -v less 1>/dev/null 2>&1; then
	alias mroe=less more=less
	export PAGER=less
	export LESS=FRdiX
	export LESSCHARSET=utf-8
fi

if command -v nvim 1>/dev/null 2>&1; then
    alias v='nvim'
fi

if command -v asdf 1>/dev/null 2>&1; then
    alias al="asdf list"
fi

# >>> Darwin/Mac OS

if [[ "${kernel_name}" == "Darwin" ]]; then

    # Brew

    # Due to changes on https://github.com/Homebrew/brew/pull/13299
    # export HOMEBREW_UPDATE_REPORT_ALL_FORMULAE=1

    # Due to changes on https://github.com/Homebrew/brew/pull/14866 indicating `brew update`
    # will only report all without API
    # documented on https://github.com/Homebrew/brew/pull/12305
    export HOMEBREW_INSTALL_FROM_API=1

    if command -v brew 1>/dev/null 2>&1; then
        alias b='brew'
        alias bo='brew outdated --greedy-auto-updates'
        alias bof='brew outdated --formulae'
        alias bi='brew info'
        alias bis='brew install'
        alias bisc='brew install --cask'
        alias bs='brew search'
        alias bu='brew update'
    fi

    if command -v bat 1>/dev/null 2>&1; then
        alias cat='bat'
    fi

    if command -v m1-terraform-provider-helper 1>/dev/null 2>&1; then
        alias m1='m1-terraform-provider-helper'
    fi

fi

# <<< Darwin/Mac OS

# >>> Debian/Linux

if [ "${kernel_name}" = "Debian" -o "${kernel_name}" = "Linux" ]; then

    if command -v apt 1>/dev/null 2>&1; then
        alias aptup='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
    fi

    if command -v batcat 1>/dev/null 2>&1; then
        alias cat='batcat'
    fi

    if command -v fdfind 1>/dev/null 2>&1; then
        alias fd='fdfind'
    fi

    # source: https://opensource.com/article/19/7/bash-aliases
    # see mounted drives
    if [ "${kernel_name}" = "Linux" ]; then
        alias mnt="mount | awk -F' ' '{ printf "%s\t%s\n",$1,$3; }' | column -t | egrep ^/dev/ | sort"
    elif [ "${kernel_name}" = "Debian" ]; then
        alias mnt='mount | grep -E ^/dev | column -t'
    fi

    if [ "${kernel_name}" = "Linux" ]
    then
        alias charm='/home/johannes/.local/bin/charm . > /dev/null 2>&1 &'
    fi

fi

# <<< Debian/Linux

# <<< ##################################### ALIAS
###############################################################################################


###############################################################################################
# >>> ##################################### FUNCTIONS

function af() { # list all functions
    # inspiration: https://www.freecodecamp.org/news/self-documenting-makefile/
    rg 'function.*?#' $ZDOTDIR/.zshrc | \
    # remove space in the front
    # sed 's/^[ \t]*//g;s/^function //' | sort | \
    sd '^\s+' '' | sd '^function ' '' | sort | \
    # get rid of undesired lines
    rg -v '^#|rg ' | \
    # nice format of functions
    awk 'BEGIN {FS = " {.*?# "}; {printf "\033[33m%-20s\033[0m %s\n", $1, $2}'
}

function myw() { date +"%Y Week %U"; } # Date in Year Week format
function mydate() { date +"%Y-%m-%d %H:%M:%S %Z"; } # Date in my format
function today() { date +"%A, %B %d, %Y"; } # Date in secondary format
function note() { echo `date +"%Y-%m-%d %H:%M:%S  "`"$*" >> ~/notes.md; } # Add a note to my file
function notes() { vim + ~/notes.md; } # View/edit notes

# add - to 2 and changed head to tail to make it zsh compatible
function gotit() { history -2 | tail -n 1 | cut -c 8- >> ~/notes.md; }

# Youtube Download to MP3 :)
if command -v youtube-dl 1>/dev/null 2>&1; then
    function yda() { # download youtube videos into mp3 format + delete video format
		youtube-dl -cix --audio-format mp3 "$@"
	}
fi

# Helper Functions
function addcmd() { # Add a command to ~/.zshrc and use it
	vim + ~/.zshrc
	source ~/.zshrc
}

function ushell() { # update shell
	source ~/.zshrc
}

function cproj() { # create dated project directory
	project_name="$@"
	# echo "Project:$project_name"
	new_project_dir="$(date +%F)-${project_name}"
	mkdir -v "$new_project_dir"

	read_me_file=$(echo "$project_name" | grep -o '^.\+\d')
	readme_file="${new_project_dir}/${new_project_dir}-readme.md"
	touch "$readme_file"
	ls -d ${new_project_dir}/*

	# capitalize each word + replace all '-' with ' ' in $project_name
	echo -e "# $(date +%F): ${(C)project_name//-/ } Project Overview" > "${readme_file}"
}

function jira_cmd() { # create dated jira markdown file
	project_name="$@"
	# echo "Project:$project_name"
	new_project_dir="$(date +%F)-${project_name}"

    # get jira ticket number
	jira_ticket_number=$(echo "$project_name" | grep -o '^.\+\d')
	readme_file="$(date +%F)-${jira_ticket_number}-readme.md"
	touch "$readme_file"

	# capitalize each word + replace all '-' with ' ' in $project_name
	echo -e "# $(date +%F): ${(C)project_name//-/ } Project Overview" > "${readme_file}"
}

function cmd() { # create dated markdown file
	project_name="$@"
	# echo "Project:$project_name"

    # create file
	md_file="$(date +%F)-${project_name}.md"
	touch "$md_file"

	# capitalize each word + replace all '-' with ' ' in $project_name
	echo -e "# $(date +%F): ${(C)project_name//-/ } Project Overview" > "${md_file}"
}

function colors() { # see range of colors
	for i in {0..255}
	do
		print -Pn "%K{$i} %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%8)):#7}:+$'\n'}
	done
}

function cdot() { # go to dotfiles directory
	dir="${HOME}/.dotfiles"
	if [[ -d "${dir}" ]]
	then
		echo "Navigating to '${dir}'"
		cd "${dir}"
	else
		echo "ERROR: Directory '${dir}' doesn't exist!"
	fi
}

if command -v asdf 1>/dev/null 2>&1; then
    function ala() { # asdf list-all for plugin and pipe to less
        asdf list-all "$1" | less
    }
fi


# >>> Oh My Zsh inspired
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/functions.zsh
function zsh_stats() {
  fc -l 1 \
    | awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' \
    | grep -v "./" | sort -nr | head -n 20 | column -c3 -s " " -t | nl
}

# take functions

# mkcd is equivalent to takedir
# shellcheck disable=SC1064,SC1072,SC1073
function mkcd takedir() {
  mkdir -p $@ && cd ${@:$#}
}

function takeurl() {
  local data thedir
  data="$(mktemp)"
  curl -L "$1" > "$data"
  tar xf "$data"
  thedir="$(tar tf "$data" | head -n 1)"
  rm "$data"
  cd "$thedir"
}

function takegit() {
  git clone "$1"
  cd "$(basename ${1%%.git})"
}

function take() {
  if [[ $1 =~ ^(https?|ftp).*\.tar\.(gz|bz2|xz)$ ]]; then
    takeurl "$1"
  elif [[ $1 =~ ^([A-Za-z0-9]\+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]; then
    takegit "$1"
  else
    takedir "$@"
  fi
}

# <<< Oh My Zsh inspired

# Moved to a function to also take care of installing depedencies from requirements.txt when present
function venv() {
    echo "creating virtual environment under .venv/..."
    python3 -m venv .venv
    echo "activating virtual environment..."
    source .venv/bin/activate
    echo "upgrading pip & setuptools..."
    pip install --upgrade pip setuptools > /dev/null
    if [[ -f requirements.txt ]]; then
        echo "found requirements.txt file - installing packages..."
        pip install -r requirements.txt
    fi
}

# >>> Debian/Linux

if [ "${kernel_name}" = "Debian" -o "${kernel_name}" = "Linux" ]; then

    # copy to clipboard on linux
    function copy() { # copy file content into clipboard (linux)
        cat "$@" | xclip -i -selection clipboard
    }

    function apts() { # apt search for specific package (linux)
        apt search "$1" | grep "^$1"
    }

    function aptl() { # apt list installed for specific package (linux)
        apt list --installed | grep "$1"
    }

    function apti() { # apt install for specific package (linux)
        sudo apt install "$1" -y
    }

fi

# <<< Debian/Linux

# >>> Darwin/Mac OS

if [[ "${kernel_name}" == "Darwin" ]]; then

    # Brew

    if command -v brew 1>/dev/null 2>&1; then
        function bup() { # brew update/upgrade formula & casks
            brew update
            result=$(brew outdated)
            if [[ $result != "" ]]; then
                echo "Upgrading Formulae"
                echo -e "$result\n"
                brew upgrade
            fi

            greedy_result=$(brew outdated --greedy-auto-updates)
            if [[ $greedy_result != "" ]]; then
                echo -e "\nUpgrading Casks with auto updates"
                echo -e "$greedy_result\n"
                brew upgrade --greedy-auto-updates
            fi

            brew cleanup
        }

        function brews() {
            local formulae="$(brew leaves | xargs brew deps --installed --for-each)"
            local casks="$(brew list --cask)"

            local blue="$(tput setaf 4)"
            local bold="$(tput bold)"
            local off="$(tput sgr0)"

            echo "${blue}==>${off} ${bold}Formulae${off}"
            echo "${formulae}" | sed "s/^\(.*\):\(.*\)$/\1${blue}\2${off}/"
            echo "\n${blue}==>${off} ${bold}Casks${off}\n${casks}"
        }
    fi

fi

# <<< Darwin/Mac OS

function zup() { # update oh my zsh + powerlevel10k
    if [[ "$SHELL" == *"zsh"* ]]; then
        if command -v p10k 1>/dev/null 2>&1; then
            echo "Updating powerlevel10k..."
            update_p10k
        fi
    fi
}

function update_p10k() { # update powerlevel10k
	git -C $ZDOTDIR/themes/powerlevel10k pull
}

# >>> AWS

function get_params() { # get aws ssm parameters
  DEFAULT_ENV=dev
  ENV=${2-$DEFAULT_ENV}
  if [ -z "$1" ]
  then
    echo "No build yml supplied"
    return 1
  fi
  echo 'using file' $1
  echo "using environtment ${ENV}"
  cat $1 |awk '/--name/{print $7}' | sed -e 's/\${[eE][nN][vV]}/'"${ENV}"'/g' | xargs -n10 aws ssm get-parameters --with-decryption --query "Parameters[*].{Name:Name,Value:Value}" --names
}

function awsprofiles() { # list aws profiles from config file
	# config=$(cat $HOME/.aws/config | grep '\[' | sed 's/\[profile //; s/\]//')
    # ignore commented lines + specific profiles
    # extract files starting with [profile
    # clean up & sort
    config=$(cat $HOME/.aws/config |\
        rg -v '^;|sso-session|default|johannes-gov' |\
        rg '^\[profile ' |\
        sd '\[profile ' '' | sd '\]' '' | sort

    )
	echo -e '\nAWS Profiles:\n'
	echo "$config"
}

function config_sso() {
    echo 'https://d-9267742869.awsapps.com/start#/'
    aws configure sso
}

function list_profile() {
    cat ~/.aws/config | grep '\[profile'
}

function request_credentials() {
    credentials=$(
        aws sts assume-role \
        --profile $1 \
        --role-arn $2 \
        --role-session-name $3
    )
}

function refresh_sso() {
    profile=$1
    temp_identity=$(aws --profile "$profile" sts get-caller-identity)
    account_id=$(echo $temp_identity | jq -r .Arn | cut -d: -f5)
    assumed_role_name=$(echo $temp_identity | jq -r .Arn | cut -d/ -f2)
    session_name=$(echo $temp_identity | jq -r .Arn | cut -d/ -f3)
    sso_region=$(aws --profile "$profile" configure get sso_region)

	if [[ $sso_region == 'us-east-1' ]]; then
        sso_region_string=''
    else
        sso_region_string="${sso_region}/"
	fi
	role_arn="arn:aws:iam::${account_id}:role/aws-reserved/sso.amazonaws.com/${sso_region_string}${assumed_role_name}"

	echo "=> requesting temporary credentials"
    request_credentials $profile $role_arn $session_name

	if [ $? -ne 0 ]; then
        aws sso login --profile "$profile"
		if [ $? -ne 0 ]; then
			exit 1
		fi
		request_credentials $profile $role_arn $session_name
	fi
	echo "=> updating ~/.aws/credentials as profile $profile"
	access_key_id=$(echo $credentials | jq -r .Credentials.AccessKeyId)
	secret_access_key=$(echo $credentials | jq -r .Credentials.SecretAccessKey)
	session_token=$(echo $credentials | jq -r .Credentials.SessionToken)
	aws configure set --profile "$profile" aws_access_key_id "$access_key_id"
	aws configure set --profile "$profile" aws_secret_access_key "$secret_access_key"
	aws configure set --profile "$profile" aws_session_token "$session_token"
	echo "[OK] done"
}

# <<< AWS

# <<< ##################################### FUNCTIONS
###############################################################################################


###############################################################################################
# >>> ##################################### WORK STUFF

DEFAULT_USER=$(whoami)

# Load work related stuff
[[ ! -f $HOME/.zsh_work.zsh ]] || source $HOME/.zsh_work.zsh

# <<< ##################################### WORK STUFF
###############################################################################################


###############################################################################################
# >>> ##################################### COMPLETIONS

if command -v aws 1>/dev/null 2>&1; then
    export AWS_CLI_AUTO_PROMPT=on-partial
    autoload bashcompinit && bashcompinit
    autoload -Uz compinit && compinit

    complete -C '/opt/homebrew/bin/aws_completer' aws
fi

# <<< ##################################### COMPLETIONS
###############################################################################################


###############################################################################################
# >>> ##################################### PATH MODIFICATIONS

# TODO: Clean up
export PATH=~/bin:$PATH
export PATH=~/.bin:$PATH
# export PATH=~/.local/bin:$PATH

# >>> CDPATH - https://jcode.me/cdpath-with-zsh/

#typeset -U path cdpath fpath

#setopt auto_cd
#cdpath=($HOME/work $HOME/work/github)

zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %d
zstyle ':completion:*:descriptions' format %B%d%b 				# bold
zstyle ':completion:*:descriptions' format %S%d%s        # invert/standout
# zstyle ':completion:*:descriptions' format %U%d%u        # underline
zstyle ':completion:*:descriptions' format %F{green}%d%f # green foreground
# zstyle ':completion:*:descriptions' format %K{blue}%d%k  # blue background
zstyle ':completion:*:complete:(cd|pushd):*' tag-order \
'local-directories named-directories path-directories'

# <<< CDPATH

# rust binaries

if test -d "$HOME/.cargo/bin"; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# /home/johannes/.asdf/installs/rust/stable/bin/rg
# export PATH="$HOME/.asdf/installs/rust/stable/bin:$PATH"
#rust_install_dir="$HOME/.asdf/installs/rust/stable"
#if test -d "$rust_install_dir"; then
#    export PATH="${rust_install_dir}/bin:$PATH"
#fi

# 2022-03-19: Have pipx install poetry
# add poetry

# awspowertools
#aws_power_tools_dir="$HOME/bin/aws-powertools"
#if test -d "$aws_power_tools_dir"; then
#    export PATH="${aws_power_tools_dir}:$PATH"
#fi

# add tyk
tyk_dir="/opt/tyk-gateway"
if test -d "$tyk_dir"; then
    export PATH="${tyk_dir}:$PATH"
fi


# <<< ##################################### PATH MODIFICATIONS
###############################################################################################

if command -v jump 1>/dev/null 2>&1; then
    eval "$(jump shell)"
fi

if command -v zoxide 1>/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi


if command -v pipx 1>/dev/null 2>&1; then
    eval "$(register-python-argcomplete pipx)"
fi

if command -v rbenv 1>/dev/null 2>&1; then
    eval "$(rbenv init - zsh)"
fi


###############################################################################################
# >>> ##################################### SHELL COMPLETIONS

# <<< ##################################### SHELL COMPLETIONS
###############################################################################################

###############################################################################################
# >>> ##################################### MISC

if command -v broot 1>/dev/null 2>&1; then
	source ${HOME}/.config/broot/launcher/bash/br
fi

if command -v fzf 1>/dev/null 2>&1; then
    eval "$(fzf --zsh)"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Disabled shared history across terminal tabs
unsetopt SHARE_HISTORY

# <<< ##################################### MISC
###############################################################################################

# Added by serverless binary installer
#export PATH="$HOME/.serverless/bin:$PATH"

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true


### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
# export PATH="$HOME/.rd/bin:$PATH" # commented out as I had to use Docker Desktop
if test -d "$HOME/.rd/bin"; then
    export PATH="$HOME/.rd/bin:$PATH"
fi
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)


# Created by `pipx` on 2022-12-25 23:07:43
export PATH="$PATH:$HOME/.local/bin"

if command -v broot 1>/dev/null 2>&1; then
	export NVM_DIR="$HOME/.nvm"
	[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
	[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
fi


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# pnpm
export PNPM_HOME="/Users/jgiorgis/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


[ -z "$ZPROF" ] || zprof
