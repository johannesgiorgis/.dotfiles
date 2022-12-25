
export ZDOTDIR="$HOME/zsh"

# M1 - assume brew installed
if [[ $(uname -p) == "arm" ]]
then
    # ensure homebrew packages are recognized before system built in
    # e.g. brew git vs. osx git
    export PATH="/opt/homebrew/bin:$PATH"
fi
