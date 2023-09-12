# Github Actions Learnings

## Repo Renaming

The biggest learning/change was the renaming of my repo to `.dotfiles`.

Why? Because I cloned my `dotfiles` repo to a local directory called `.dotfiles` and all scripts were set up to run under the `.dotfiles/` directory. This caused issues as Github Action runners checked out the `dotfiles` repo and that's where the scripts were called from.

Googling around led me to this [issue](https://github.com/actions/checkout/issues/197#) (open as of Sep 2023) and this [issue comment](https://github.com/actions/checkout/issues/197#issuecomment-829560171) where someone successfully renamed their repo by copying it over.

After some trial and error, the easiest solution was simply to rename my repo to from `dotfiles` to `.dotfiles`. This would make it consistent everywhere else and simplify my adoption of Github Actions. Github Action runners would check out the same directory and scripts would run with no issues 🎉 A simple fix to a silly solution.

Second learning was something I came across was from the below article on using Github Actions for continuous integration of MacOS based dotfiles. Specifically, the use of environment variables and determining where you were running.

- [CI your MacOS dotfiles with GitHub Actions!](https://mattorb.com/ci-your-dotfiles-with-github-actions/)
- [dotfiles repo](https://github.com/mattorb/dotfiles/tree/master)

## Ansible Current Workig Directory for Symlinks

What was I solving? I had the idea of installing zsh via my `zsh` role and running `source zsh` as part of my Github Action test workflow to verify everything works as expected for both MacOS and Linux systems. My current setup simply installed the `timewarrior` package and verified its presence via `command -v timew`.

I hit an issue where the symlinking of files were hardcoded to expect $HOME/.dotfiles/files/<file-to-symlink>. Running within Github CI systems would lead to this path/file not existing.

How to solve it? I needed ansible to inform me of my current working directory. Quick Google search led to Ansible special variables - `playbook_dir`:

> The path to the directory of the current playbook being executed. NOTE: This might be different than directory of the playbook passed to the ansible-playbook command line when a playbook contains a import_playbook statement.

So my old symlink commands:

```yml
- name: ZSH - Symlink zsh/ to $HOME/zsh/
  file:
    src: "{{ dotfiles_home }}/files/zsh"
    dest: "{{ dotfiles_user_home }}/zsh"
    state: link
```

became

```yml
- name: ZSH - Symlink zsh/ to $HOME/zsh/
  file:
    src: "{{ playbook_dir }}/files/zsh"
    dest: "{{ dotfiles_user_home }}/zsh"
    state: link
```

A one variable switcheroo and I had it working 🎉

- [Ansible Special Variables - playbook_dir](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html#term-playbook_dir)
