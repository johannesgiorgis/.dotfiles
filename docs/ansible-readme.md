# Ansible Section

- [Resources](#resources)
- [Issues](#issues)
- [Unexpected Test](#unexpected-test)
- [Installation Guide](#installation-guide)
- [Answer to Use ansible package module to work with apt and homebrew](#answer-to-use-ansible-package-module-to-work-with-apt-and-homebrew)
    - [Declare `become: yes` (root) globally for Linux only](#declare-become-yes-root-globally-for-linux-only)
    - [Address packages that need platform-specific treatment as-needed with when](#address-packages-that-need-platform-specific-treatment-as-needed-with-when)
    - [Map package name discrepancies with variables](#map-package-name-discrepancies-with-variables)
    - [Combining everything into a real play](#combining-everything-into-a-real-play)

## Resources

Below are resources I came across that helped me migrate to ansible

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

## Issues

I was unable to install my desired theeme `powerlevel10k` via antigen. I kept getting the following error:

```sh
➜ antigen theme https://github.com/romkatv/powerlevel10k powerlevel10k
(anon):source:27: no such file or directory: /home/johannes/.antigen/internal/p10k.zsh
```

So I decided to use Oh-My-Zsh to manage my theme only to find out the theme wouldn't load.

Googling around led me to this github issue thread <https://github.com/romkatv/powerlevel10k/issues/825> where the theme author himself says he doesn't use a plugin manager himself. Also it seems antigen hasn't been updated in a while. Since I had everything working perfectly via using Oh-My-Zsh, I'll set up Ansible to do just that.

## Unexpected Test

On September 10th, I accidentally messed up my initial installation of Pop_OS! via trying to install some Virtual Machine related installations the Pop!_Shop prompted me with. Re-installing from the ISO image I originally used, there were too many updates so I grabbed a more recent ISO image from their website.

Re-installing Pop_OS! was an unexpected test to see how my Ansible work was coming along. I was back to being productive on VS Code and adding more cool stuff before long. It's awesome!


## Installation Guide

This directory contains all the ansible related material.

**Note**: I used the below strategy to install meld (2020-09-21). It makes things much simpler!

## Answer to Use ansible package module to work with apt and homebrew

- <https://stackoverflow.com/questions/63242221/use-ansible-package-module-to-work-with-apt-and-homebrew>

If you want a single set of tasks that flexible enough for for multiple Linux package managers and macOS brew, the choice is either more logic or more duplication.

These three patterns should help. They still have repetition and boilerplate code, but that's the territory we're in with Ansible plays for cross-platform.

1. Declare `become: yes` (root) globally for Linux only
1. Address packages that need platform-specific treatment as-needed with `when`
    - This might be `--head` for `brew`, or setting up a PPA for `apt`, etc
1. Map package name discrepancies with variables
    - For example: `brew install ncurses`, `apt install libncurses5-dev`, and `dnf install ncurses-devel` are all the same library.

### Declare `become: yes` (root) globally for Linux only

For Linux hosts, switching to root for installation is the intended behavior. For macOS a la Homebrew, installing as root is not good. So, we need `become: yes` (`true`) when using `brew`, and `become: no` (`false`) otherwise (for Linux).

In your example the `become` directive is nested inside each task ("step"). To prevent duplication, invoke `become` at a higher lexical scope, before the tasks start. The subsequent tasks will then inherit the state of `become`, which is set based on a conditional expression.

Unfortunately a variable for `become` at the root playbook scope will be undefined and throw an error before the first task is run:

```yaml
# playbook.yml
- name: Demo
  hosts: localhost
  connection: local
  # This works
  become: True
  # This doesn't - the variable is undefined
  become: "{{ False if ansible_pkg_mgr == 'brew' else True }}"
  # Nor does this - also undefined
  become: "{{ False if ansible_os_family == 'Darwin' else True }}"

  tasks:
    # ...
```

To fix this, we can store the tasks in another file and [import](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_includes.html#including-and-importing-task-files) them, or wrap the tasks in a [block](https://docs.ansible.com/ansible/2.5/user_guide/playbooks_blocks.html). Either of these patterns will provide a chance to declare `become` with our custom variable value in time for the tasks to pick it up:

```yaml
# playbook.yml
---
- name: Demo
  hosts: localhost
  connection: local
  vars:
    # This variable gives us a boolean for deciding whether or not to become
    # root. It cascades down to any subsequent tasks unless overwritten.
    should_be_root:  "{{ true if ansible_pkg_mgr != 'brew' else false }}"

    # It could also be based on the OS type, but since brew is the main cause
    # it's probably better this way.
    # should_be_root: "{{ False if ansible_os_family == 'Darwin' else True }}"

  tasks:
    # Import the tasks from another file, which gives us a chance to pass along
    # a `become` context with our variable:
    - import_tasks: test_tasks.yml
      become: "{{ should_be_root }}"

    # Wrapping the tasks in a block will also work:
    - block:
      - name: ncurses is present
        package:
          name: [libncurses5-dev, libncursesw5-dev]
          state: present
      - name: cmatrix is present
        package:
          name: cmatrix
          state: present
      become: "{{ should_be_root }}"
```

Now there is a single logic check for `brew` and a single `before` directive (depending on which task pattern above is used). All tasks will be executed as the root user, unless the package manager in use is `brew`.

### Address packages that need platform-specific treatment as-needed with when

The [Package Module](https://docs.ansible.com/ansible/latest/modules/package_module.html) is a great convenience but it's quite limited. By itself it only works for ideal scenarios; meaning, a package that doesn't require any special treatment or flags from the underlying package manager. All it can do is pass the literal string of the package to install, the `state`, and an optional parameter to force use of a specific package manager executable.

Here's an example that installs `wget` with a nice short task and only becomes verbose to handle `ffmpeg`'s special case when installed with `brew`:

```yaml
# playbook.yml
# ...
  tasks:
    # wget is the same among package managers, nothing to see here
    - name: wget is present
      when: ansible_pkg_mgr != 'brew'
      package:
        name: wget
        state: present

    # This will only run on hosts that do not use `brew`, like linux
    - name: ffmpeg is present
      when: ansible_pkg_mgr != 'brew'
      package:
        name: ffmpeg
        state: present

    # This will only run on hosts that use `brew`, i.e. macOS
    - name: ffmpeg is present (brew)
      when: ansible_pkg_mgr == 'brew'
      homebrew:
        name: ffmpeg
        # head flag
        state: head
        # --with-chromaprint --with-fdk-aac --with-etc-etc
        install_options: with-chromaprint, with-fdk-aac, with-etc-etc
```

The play above would produce this output for `ffmpeg` against a Linux box:

```sh
TASK [youtube-dl : ffmpeg is present] ******************************************
ok: [localhost]

TASK [youtube-dl : ffmpeg is present (brew)] ***********************************
skipping: [localhost]
```

### Map package name discrepancies with variables

This isn't specifically part of your question but it's likely to come up next.

The [Package Module](https://docs.ansible.com/ansible/latest/modules/package_module.html) docs also mention:

> Package names also vary with package manager; this module will not "translate" them per distro. For example libyaml-dev, libyaml-devel.

So, we're on our own to handle cases where the same software uses different names between package manager platforms. This is quite common.

There are multiple patterns for this, such as:

- Use [separate variable files](https://docs.ansible.com/ansible/latest/modules/include_vars_module.html#examples) for each OS/distro and import them conditionally
- [Use a role with its own variables](https://stackoverflow.com/questions/54944080/installing-multiple-packages-in-ansible#answer-58644752)
- Use the same package manager across platforms, such as [Homebrew](https://docs.brew.sh/Homebrew-on-Linux) or [Conda](https://docs.conda.io/en/latest/)
- Compile everything from source via git

None of them are very pleasant. Here is an approach using a [role](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html). Roles do involve more boilerplate and directory juggling, but in exchange they provide modularity and a local variable environment. When a set of tasks in a role requires more finagling to get right, it doesn't end up polluting other task sets.

```yaml
# playbook.yml
---
- name: Demo
  hosts: localhost
  connection: local
  roles:
    - cmatrix

# roles/cmatrix/defaults/main.yml
---
ncurses:
  default:
    - ncurses
  # Important: these keys need to exactly match the name of package managers for
  # our logic to hold up
  apt:
    - libncurses5-dev
    - libncursesw5-dev
  brew:
    - pkg-config
    - ncurses

# roles/cmatrix/tasks/main.yml
---
- name: cmatix and its dependencies are present
  become: "{{ should_be_root }}"
  block:
    - name: ncurses is present
      package:
        name: '{{ item }}'
        state: latest
      loop: "{{ ncurses[ansible_pkg_mgr] | default(ncurses['default']) }}"

    - name: cmatrix is present
      when: ansible_pkg_mgr != 'brew'
      package:
        name: cmatrix
        state: present
```

The task for `ncurses` looks for an array of items to loop through keyed by the corresponding package manager. If the package manager being used is not defined in the variable object, a Jinja default filter is employed to reference the `default` value we set.

With this pattern, adding support for another package manager or additional dependencies simply involves updating the variable object:

```yaml
# roles/cmatrix/defaults/main.yml
---
ncurses:
  default:
    - ncurses
  apt:
    - libncurses5-dev
    - libncursesw5-dev
    # add a new dependency for Debian
    - imaginarycurses-dep
  brew:
    - pkg-config
    - ncurses
  # add support for Fedora
  dnf:
    - ncurses-devel
```

### Combining everything into a real play

Here's a full example covering all three aspects. The playbook has two roles that each use the correct `become` value based on a single variable. It also incorporates an special cases for `cmatrix` and `ffmpeg` when installed with `brew`, and handles alternate names for ncurses between package managers.

```yaml
# playbook.yml
---
- name: Demo
  hosts: localhost
  connection: local
  vars:
    should_be_root:  "{{ true if ansible_pkg_mgr != 'brew' else false }}"
  roles:
    - cmatrix
    - youtube-dl
```

```yaml
# roles/cmatrix/defaults/main.yml
ncurses:
  default:
    - ncurses
  apt:
    - libncurses5-dev
    - libncursesw5-dev
  brew:
    - pkg-config
    - ncurses
  dnf:
    - ncurses-devel
```

```yaml
# roles/cmatrix/tasks/main.yml
---
- name: cmatrix and dependencies are present
  # A var from above, in the playbook
  become: "{{ should_be_root }}"

  block:
    - name: ncurses is present
      package:
        name: '{{ item }}'
        state: latest
      # Get an array of the correct package names to install from the map in our
      # default variables file
      loop: "{{ ncurses[ansible_pkg_mgr] | default(ncurses['default']) }}"

    # Install as usual if this is not a brew system
    - name: cmatrix is present
      when: ansible_pkg_mgr != 'brew'
      package:
        name: cmatrix
        state: present
    # If it is a brew system, use this instead
    - name: cmatrix is present (brew)
      when: ansible_pkg_mgr == 'brew'
      homebrew:
        name: cmatrix
        state: head
        install_options: with-some-option
```

```yaml
# roles/youtube-dl/tasks/main.yml
---
- name: youtube-dl and dependencies are present
  become: "{{ should_be_root }}"

  block:
    - name: ffmpeg is present
      when: ansible_pkg_mgr != 'brew'
      package:
        name: ffmpeg
        state: latest
    - name: ffmpeg is present (brew)
      when: ansible_pkg_mgr == 'brew'
      homebrew:
        name: ffmpeg
        state: head
        install_options: with-chromaprint, with-fdk-aac, with-etc-etc

    - name: atomicparsley is present
      package:
        name: atomicparsley
        state: latest

    - name: youtube-dl is present
      package:
        name: youtube-dl
        state: latest
```

The result for Ubuntu:

```sh
$ ansible-playbook demo.yml
[WARNING]: provided hosts list is empty, only localhost is available. Note that
the implicit localhost does not match 'all'

PLAY [Demo] ********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [cmatrix : ncurses is present] ********************************************
ok: [localhost] => (item=libncurses5-dev)
ok: [localhost] => (item=libncursesw5-dev)

TASK [cmatrix : cmatrix is present] ********************************************
ok: [localhost]

TASK [cmatrix : cmatrix is present (brew)] *************************************
skipping: [localhost]

TASK [youtube-dl : ffmpeg is present] ******************************************
ok: [localhost]

TASK [youtube-dl : ffmpeg is present (brew)] ***********************************
skipping: [localhost]

TASK [youtube-dl : atomicparsley is present] ***********************************
ok: [localhost]

TASK [youtube-dl : youtube-dl is present] **************************************
ok: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=6    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
```
