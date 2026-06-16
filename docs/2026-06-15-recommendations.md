# Dotfiles Repo Recommendations

Generated: 2026-06-15

Generated from a review session covering the zshrc, dotfiles repo structure, tooling, and
comparisons with other dotfiles repos.

---

## High Priority

### 1. Fix asdf role — switch from git clone to Homebrew
The asdf role currently clones from GitHub. In v0.16+, asdf was rewritten as a Go binary
and `asdf.sh` no longer exists, breaking the shell integration. Homebrew is already at
v0.19.0 (in sync with latest). Update `roles/infrastructure/asdf/tasks/main.yml` to use
the `homebrew` module instead of the git clone approach.

### 2. Update Terraform versions
`roles/infrastructure/terraform/` pins versions 1.0.2–1.2.1. Terraform is currently at
1.10.x. Given `tfsec` and `checkov` are in the work role, these are likely in active use.
Run `asdf list-all terraform` and update to current + LTS versions.

### 3. Audit and remove unused software roles
Several notes/task apps exist side by side: Craft, Joplin, Notesnook, Simplenote, Trello,
Todoist. A fresh machine provision would install all of them. Do a pass to remove roles for
apps no longer in use.

---

## Structure & Organisation

### 4. Add a new top-level `config/` category
`zsh`, `git`, `vim`, and `bin-folder` are in `infrastructure/` but are fundamentally
different from Docker, rancher, or OS setup. They are dotfile config roles — the original
purpose of the repo. Most well-regarded dotfiles repos separate shell/editor config from
infrastructure provisioning. Suggested new structure:

```
roles/
  config/          # zsh, git, vim, bin-folder
  cli/             # common-cli, taskwarrior, youtube-dl
  infrastructure/  # docker, asdf, runtimes, OS-specific setup
  software/        # desktop applications
  work/            # work-specific tooling
```

### 5. Prefix language runtime roles consistently
Python, Node.js, Go, Rust, Deno, Terraform, and Hugo are all managed via asdf but scattered
through `infrastructure/` with no naming convention. Prefixing them (e.g. `lang-python`,
`lang-nodejs`, `lang-golang`) would make them sort together and be immediately identifiable
without reading the role content.

### 6. Resolve `linux-*` role placement inconsistency
Linux system utilities are split between `infrastructure/` and `software/` with no clear
rule:
- In `infrastructure/`: `linux-gnome-extensions`, `linux-redshift`, `linux-openssh`
- In `software/`: `linux-blueman`, `linux-timeshift`, `linux-conky-manager`

Suggested rule: Linux system/desktop utilities → `infrastructure/`, GUI end-user
applications → `software/`. Move `linux-blueman` and `linux-timeshift` to
`infrastructure/`.

### 7. Fix platform-prefix naming inconsistency in `software/`
Some macOS-only roles are prefixed (`macos-shottr`, `macos-shureplus-motiv`) but others
aren't (`discord`, `signal`, `vscodium`, `craftnotes`, `dropbox` — all macOS-only). Either
prefix all macOS-only roles with `macos-` or drop the prefix convention and rely on task
conditionals alone. Currently it's mixed.

### 8. Wire AI tooling scripts into a role
`bin/setup-claude-code-aws.sh`, `bin/claude-bedrock`, and `bin/claude-bedrock.sh` exist as
loose scripts but aren't provisioned by any role. A fresh machine won't get them
automatically. Add a `cli/ai-tools` role or include them in the `work/` role.

---

## Code Quality

### 9. Remove or archive the `atest` role
`roles/cli/atest/` is 100+ lines of commented-out Ansible experimentation. It adds noise
and confusion. Move any useful notes to `docs/` and delete the role, or at minimum remove
it from `dotfiles.yml`.

### 10. Update `common-cli` README
`roles/cli/common-cli/README.md` lists 32 tools but `defaults/main.yml` has a different
set. A README that contradicts the code is worse than no README. Either keep it in sync or
delete it.

### 11. Clean up `docs/todo.md`
Everything in the Install List is checked off. The file's useful content is now the
`Configuration Save`, `Manual Setup`, and `Potential Installations` sections. Consider
archiving the completed items or restructuring into a current backlog.

---

## zshrc Specific

### 12. Move `compinit -C` between the two plugin loops
`compinit` must run after plugins are added to `fpath` (loop 1) but before plugins are
sourced (loop 2), otherwise `compdef` is unavailable when plugin files are sourced. Place
it between the two loops at line ~123.
> **Status**: Already done ✓

### 13. Lazy-load NVM
NVM sourcing adds ~200–500ms to startup. The lazy-load pattern defers it until first use:
```zsh
export NVM_DIR="$HOME/.nvm"
nvm() {
    unfunction nvm
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"
    nvm "$@"
}
```
> **Status**: Already done ✓

### 14. Replace `uname -p` with `$CPUTYPE`
Line 19 spawns a subprocess for architecture detection. Use the zsh builtin instead:
```zsh
if [[ $CPUTYPE == arm* ]]
```

### 15. Replace `$(whoami)` with `$USER`
`DEFAULT_USER=$(whoami)` spawns a subprocess. `$USER` is already set in the environment
and is a direct replacement.

### 16. Remove dead `zstyle` description assignments
Lines 676–681 set `:completion:*:descriptions` format four times consecutively. Only the
last one (`%F{green}%d%f`) is active. Remove the first three.

---

## Tooling Considerations

### 17. Consider chezmoi for config file management (not a replacement for Ansible)
Ansible is the right tool for workstation provisioning (software install, OS config).
However for config file templating — `.gitconfig`, `.zshenv`, `.p10k.zsh` — chezmoi offers
a cleaner model:
- Native Bitwarden integration (pull secrets at apply time, no plaintext values in repo)
- Simpler per-machine templating vs Jinja2 + task + handler
- The two tools don't conflict: Ansible installs software, chezmoi manages config files

Only worth pursuing if current Ansible config templating is causing pain, particularly
around secrets or per-machine differences.

### 18. Add a Brewfile
Top-tier dotfiles repos (driesvints, sobolevn, webpro) use a `Brewfile` as a declarative
list of all Homebrew packages. It complements the Ansible roles and makes the full
installed package set reviewable in one place. Generate one from current state:
```sh
brew bundle dump --file=Brewfile
```

---

## Nice to Have

### 19. `docker` role has no macOS implementation
The role only provisions Docker on Debian. Since macOS is the primary machine, either add
Docker Desktop (cask) or document that Rancher Desktop is the macOS equivalent (you already
have a `rancher` role).

### 20. `granted` role is macOS-only but not prefixed
`roles/infrastructure/granted/` has a Debian TODO. Either implement it or rename to
`macos-granted` to be consistent.

### 21. `p10k.zsh` has an old backup copy in `files/`
Two p10k config files are present — one current, one backup (`.old`). Remove the backup.
