# New Computer Setup Guide

This guide documents me setting up my new Pop!_OS computer.

- Install LastPass on Firefox (Not Needed)
- Login to GitHub -> Clone dotfiles
- Clone dotfiles repo - `git clone https://github.com/johannesgiorgis/dotfiles.git ~/.dotfiles`
- Verify git is installed
- Create new SSH KEY - Install XCLIP -> Add it to SSH & GPG Keys on GIthub
- Run bash bin/dot-bootstrap -> will install ansible

Run `sudo apt update + sudo apt upgrade -y`

Run `bash bin/dot-bootstrap -t linux-gnome-extensions`

---

## Set Hostname to `deepblue`

```sh
johannes@pop-os:~$ sudo hostnamectl set-hostname deepblue
[sudo] password for johannes: 
johannes@pop-os:~$ exec bash
johannes@deepblue:~$
```

## Get dotfiles repo

### Option 1

1. Clone github repo: `git clone https://github.com/johannesgiorgis/dotfiles.git ~/.dotfiles`

### Option 2

1. Install LastPass on Firefox (comes pre-installed on Pop OS) - <https://addons.mozilla.org/en-CA/firefox/addon/lastpass-password-manager/>
1. Clone github repo: `git clone git@github.com:johannesgiorgis/dotfiles.git ~/.dotfiles`

## Install Software

```sh
cd ~/.dotfiles

git checkout explore-ansible

# install ansible
bash bin/dot-bootstrap

bash bin/dot-bootstrap -t popos-initial-configuration

bash bin/dot-bootstrap -t vscode

bash bin/dot-bootstrap -t zsh

bash bin/dot-bootstrap -t ripgrep

bash bin/dot-bootstrap -t bat

bash bin/dot-bootstrap -t linux-initial-configuration

bash bin/dot-bootstrap -t asdf

bash bin/dot-bootstrap -t xclip

xclip -selection clipboard < ~/.ssh/id_ed25519.pub # add to Github

bash bin/dot-bootstrap -t broot

# add to broot role
broot --install

bash bin/dot-bootstrap -t linux-terminator

bash bin/dot-bootstrap -t linux-gnome-extensions
```
