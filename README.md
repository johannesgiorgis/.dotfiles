# Dotfiles

Various settings for the tools I use. My dotfile repository was initially created by a combination of following Victoria's excellent [How to set up a fresh Ubuntu Desktop using only dotfiles and bash scripts] and structured to match Holman's dotfiles ([Github - Holman's Dotfiles]).

## Setup

### Linux - Debian

To set up a new Debian based Linux system, do the following initial steps upon logging in:

```sh
# Downloads and install xclip BEFORE running any updates
$ sudo apt-get install xclip

# Run Updates
$ sudo apt update -y && sudo apt upgrade -y

# Navigate to GitHub and log in -> Settings -> SSH & GPG Keys -> New SSH Key

# Generate new SSH Key
$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Add newly created SSH key to GitHub account

# Use xclip to copy content of public key so you can paste it in GitHub
$ xclip -sel clip < ~/.ssh/id_rsa.pub
# Copies the contents of the id_rsa.pub file to your clipboard

# Clone dotfiles
$ git clone git@github.com:johannesgiorgis/dotfiles.git ~/.dotfiles

# Run ansible playbook
$ cd ~/.dotfiles
$ bash bin/dot-bootstrap <tag>
```

Doing it this way ensures that you can run your updates while you get set up to clone the repo and start the rest of the set up.

- [Connecting to GitHub with SSH]
- [Generate a New SSH Key]
- [Add new SSH key to GitHub account]

### MacOS

```sh
# Install Command Line Developer Tools
xcode-select --install


git clone https://github.com/johannesgiorgis/dotfiles.git ~/.dotfiles
cd ~/.dotfiles  
git checkout explore-ansible-2
git pull
bash bin/dot-bootstrap # install homebrew/ansible

# Add home-brew to PATH (manually) from installation output
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/johannes/.zprofile

# disable analytics
export HOMEBREW_NO_ANALYTICS=1
brew analytics off

# Install packages
$ bash bin/dot-bootstrap <tag>
```

## Updates

When doing a meaningful upgrade, tag it via:

```sh
git tag -a <dotfiles-version> -m 'Dotfiles <dotfiles-version>: <some-description>'

# example
git tag -a v1.0 -m 'Dotfiles v1.0: The Bash Way'
```

## Testing

<!-- TODO: Convert to Github Action -->
Run the following:

```sh
# build docker image and run docker container
$ make docker-all

# once in the docker container, run
$ bash scripts/bootstrap.sh | tee setup_log.log

# another testing
$ bash scripts/bootstrap.sh | tee log-2020-05-10-bootstrap-v<num>.log 2>&1
```

## Dotfiles V2

= [to-do list](docs/todo.md)

This is currently a wishlist.

As I continue to customize the various scripts, I wanted more control over certain functionality - let user choose which custom program to install, not install, etc. Yet I don't want to write and go throught the trial and error of bash scripting.

This led me to research how to manage dotfiles and found several options - ansible, dotstow. I came across several articles:

- <https://medium.com/espinola-designs/manage-your-dotfiles-with-ansible-6dbedd5532bb>
- <https://github.com/sloria/dotfiles>
- <https://github.com/elnappo/dotfiles>
- <https://dev.to/alexdesousa/managing-dotfiles-with-ansible-3kbg>
- <https://github.com/alexdesousa/dotfiles>
- <https://medium.com/@codejamninja/dotstow-the-smart-way-to-manage-your-dotfiles-8a0a8b6d984c>

Folks are using Python, Typescript to write wrapper programs around their .dotfiles management. Maybe some combination of bash + ansible could work.

Simplifying zsh shell to remove dependency on Oh My Zsh!

- https://github.com/Phantas0s/.dotfiles
- https://github.com/ohmyzsh/ohmyzsh/tree/master/lib (Used for references)

Zsh history

- https://www.soberkoder.com/better-zsh-history/
- https://gist.github.com/matthewmccullough/787142

## Reference

- [Automated Testing of dotfiles]
- [How to set up a fresh Ubuntu Desktop using only dotfiles and bash scripts]
- [Github - Holman's Dotfiles]
- [Github - Victoria Drake's Dotfiles]
- [Moving to ZSH: Customizing the ZSH Prompt]

---

[//]: # (References)

[Automated Testing of dotfiles]: https://michael.mior.ca/blog/automated-testing-of-dotfiles/
[How to set up a fresh Ubuntu Desktop using only dotfiles and bash scripts]: https://www.freecodecamp.org/news/how-to-set-up-a-fresh-ubuntu-desktop-using-only-dotfiles-and-bash-scripts/
[Github - Holman's Dotfiles]: https://github.com/holman/dotfiles
[Github - Victoria Drake's Dotfiles]: https://github.com/victoriadrake/dotfiles
[Moving to ZSH: Customizing the ZSH Prompt]: https://scriptingosx.com/2019/07/moving-to-zsh-06-customizing-the-zsh-prompt/
[Connecting to GitHub with SSH]: https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
[Generate a New SSH Key]: https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
[Add new SSH key to GitHub account]: https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account

hello there