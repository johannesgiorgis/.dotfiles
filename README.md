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

## Testing

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

**Current**: Migrating to Ansible

- Pop!_OS Post Install 5 Steps - <https://techhut.tv/5-things-to-do-after-installing-pop-os/>
- <https://github.com/kespinola/dotfiles>
- <https://github.com/sloria/dotfiles>
- VS Code Role Inspiration: <https://github.com/gantsign/ansible-role-visual-studio-code>
- Zsh + Antigen + Oh-My-Zsh Role Inspiration: <https://github.com/gantsign/ansible_role_antigen>
- Oh-My-Zsh Role Inspiration: <https://github.com/gantsign/ansible-role-oh-my-zsh>
- Interesting organization: <https://github.com/tentacode/blacksmithery>
- Gnome Extensions Inspiration: <https://github.com/jaredhocutt/ansible-gnome-extensions>
- Customize Pop OS: <https://www.youtube.com/watch?v=LHj2ulIm7AQ>
- Dropbox Inspirations:
    - <https://github.com/AlbanAndrieu/ansible-dropbox>
    - <https://github.com/Oefenweb/ansible-dropbox>
    - <https://github.com/geerlingguy/ansible-role-docker> (Used this one)
- Slack role Inspiration: <https://github.com/wtanaka/ansible-role-slack>
- Sublime-text role Inspiration: <https://github.com/chaosmail/ansible-roles-sublime-text>
- Docker role: <https://github.com/geerlingguy/ansible-role-docker>
- PyCharm role: <https://github.com/Oefenweb/ansible-pycharm>
- Handle Apt & Homebrew with Package: <https://stackoverflow.com/questions/63242221/use-ansible-package-module-to-work-with-apt-and-homebrew>
- OpenSSH
    - <https://github.com/linuxhq/ansible-role-openssh>
    - <https://github.com/archf/ansible-openssh-server>
- PostgreSQL: <https://github.com/geerlingguy/ansible-role-postgresql>
- Custom Login Screen - <https://techhut.tv/lightdm-custom-login-screen-in-linux/>
- Linux Display Manager: <https://github.com/ypid/ansible-dm>
- LightDM Webkit Greeter role: <https://github.com/void-ansible-roles/lightdm-webkit-greeter>
- Jetbrains Toolbox role: <https://github.com/jaredhocutt/ansible-jetbrains-toolbox>
- Firefox: <https://github.com/alzadude/ansible-firefox>
- Chusiang Ubuntu Ansible Setup: <https://github.com/chusiang/hacking-ubuntu.ansible>
- Nerd-fonts: <https://github.com/drew-kun/ansible-nerdfonts>
- Workstation: <https://github.com/leberrem/workstation>
- Mac Specific Dotfiles: <https://gitlab.dwbn.org/TobiasSteinhoff/dotfiles-ansible/-/tree/8f251067b69b118b28510551ffcea423ef032044/>
- Automating My Dev Setup
    - <https://pbassiner.github.io/blog/automating_my_dev_setup.html>
    - <https://github.com/pbassiner/dev-env>
- dconf-settings: <https://github.com/jaredhocutt/ansible-dconf-settings>

### Issues

I was unable to install my desired theeme `powerlevel10k` via antigen. I kept getting the following error:

```sh
➜ antigen theme https://github.com/romkatv/powerlevel10k powerlevel10k
(anon):source:27: no such file or directory: /home/johannes/.antigen/internal/p10k.zsh
```

So I decided to use Oh-My-Zsh to manage my theme only to find out the theme wouldn't load.

Googling around led me to this github issue thread <https://github.com/romkatv/powerlevel10k/issues/825> where the theme author himself says he doesn't use a plugin manager himself. Also it seems antigen hasn't been updated in a while. Since I had everything working perfectly via using Oh-My-Zsh, I'll set up Ansible to do just that.

### Unexpected Test

On September 10th, I accidentally messed up my initial installation of Pop_OS! via trying to install some Virtual Machine related installations the Pop!_Shop prompted me with. Re-installing from the ISO image I originally used, there were too many updates so I grabbed a more recent ISO image from their website.

Re-installing Pop_OS! was an unexpected test to see how my Ansible work was coming along. I was back to being productive on VS Code and adding more cool stuff before long. It's awesome!

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
