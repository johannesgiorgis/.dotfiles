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

## Installation Order

```sh
scripts/bootstrap.sh -> bin/dot -> install_dotfiles
  - bin/dot -> install OS specific (Mac OS or Linux) -> install_all.sh
  - install_all.sh - sequentially runs all files ending with install.sh
    - currently: ./zsh/oh_my_zsh_install.sh
```

## Dotfiles V2

= [to-do list](todo.md)

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

Below is from the original Holman dotfiles README.md:

## holman does dotfiles

Your dotfiles are how you personalize your system. These are mine.

I was a little tired of having long alias files and everything strewn about
(which is extremely common on other dotfiles projects, too). That led to this
project being much more topic-centric. I realized I could split a lot of things up into the main areas I used (Ruby, git, system libraries, and so on), so I structured the project accordingly.

If you're interested in the philosophy behind why projects like these are
awesome, you might want to [read my post on the
subject](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/).

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `script/bootstrap`.

## what's inside

A lot of stuff. Seriously, a lot of stuff. Check them out in the file browser
above and see what components may mesh up with you.
[Fork it](https://github.com/holman/dotfiles/fork), remove what you don't
use, and build on what you do use.

## components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **topic/install.sh**: Any file named `install.sh` is executed when you run `script/install`. To avoid being loaded automatically, its extension is `.sh`, not `.zsh`.
- **topic/\*.symlink**: Any file ending in `*.symlink` gets symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.

## install

Run this:

```sh
git clone https://github.com/holman/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

`dot` is a simple script that installs some dependencies, sets sane macOS
defaults, and so on. Tweak this script, and occasionally run `dot` from
time to time to keep your environment fresh and up-to-date. You can find
this script in `bin/`.

## bugs

I want this to work for everyone; that means when you clone it down it should
work for you even though you may not have `rbenv` installed, for example. That
said, I do use this as _my_ dotfiles, so there's a good chance I may break
something if I forget to make a check for a dependency.

If you're brand-new to the project and run into any blockers, please
[open an issue](https://github.com/holman/dotfiles/issues) on this repository
and I'd love to get it fixed for you!

## thanks

I forked [Ryan Bates](http://github.com/ryanb)' excellent
[dotfiles](http://github.com/ryanb/dotfiles) for a couple years before the
weight of my changes and tweaks inspired me to finally roll my own. But Ryan's
dotfiles were an easy way to get into bash customization, and then to jump ship
to zsh a bit later. A decent amount of the code in these dotfiles stem or are
inspired from Ryan's original project.

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
