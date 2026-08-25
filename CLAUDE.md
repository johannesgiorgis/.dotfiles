# CLAUDE.md

Guidance for Claude Code when working in this repo.

## What this is

Personal dotfiles managed as an Ansible playbook (`dotfiles.yml`), driven by the
`bin/doi` wrapper script. Targets both macOS (Darwin, homebrew) and Debian/Pop!_OS
(apt) — many roles branch on `ansible_pkg_mgr` / `ansible_os_family` to support both.

## Running things

- `bash bin/doi` — list all available tags
- `bash bin/doi -t <tag>` — run one role by tag (e.g. `bash bin/doi -t vim`)
- `bash bin/doi -t <tag1>,<tag2>` — run multiple tags
- `bash bin/doi -f <substring>` — find tags matching a substring
- `bash bin/doi -a -t <tag>` — pass `-a` to enable `ask_become_pass` (roles needing sudo)
- `make list-ansible-tags` — same as `bash bin/doi`
- `make ansible-inventory` / `make ansible-info` — inspect ansible inventory/facts for `local` host
- `make ci` — run GitHub Actions locally via `act`

## Adding or editing a role

Roles live under `roles/{cli,infrastructure,software}/<name>/tasks/main.yml` and must
be registered in `dotfiles.yml` as `{ role: <group>/<name>, tags: [<name>] }`, in
alphabetical order within its group (cli / infrastructure / software / work).

Common task shapes (copy the closest existing role rather than inventing a new
pattern):
- **macOS package**: `homebrew` (formula) or `homebrew_cask` (GUI app), guarded with
  `when: ansible_os_family == "Darwin"` or `when: ansible_pkg_mgr == 'homebrew'`.
- **Debian package**: `apt`/`package` module, guarded with
  `when: ansible_pkg_mgr == 'apt'` or `ansible_os_family in ["Debian"]`, usually
  `become: "{{ should_be_root }}"`.
- **Dotfile symlink**: back up any existing file (`mv ... ~/.foo.bak`, `creates:` guard)
  then `file: state: link` from `files/` into `{{ dotfiles_user_home }}`.
- **Direct installer script**: `ansible.builtin.shell` with a `creates:` guard so it's
  idempotent (see `roles/cli/claude-code/tasks/main.yml`).

Task names are prefixed with the role name in caps (`VIM - ...`, `SLACK - ...`).

## Conventions

- Ansible linting is editor-side only (the `redhat.ansible` VS Code extension, see
  `group_vars/all/vscode.yml`), not a CI gate. Existing `# noqa: <rule>` comments (e.g.
  in `roles/cli/vim/tasks/main.yml`) are silencing that editor lint — match the same
  pattern rather than restructuring around a rule that doesn't apply.
- Shell scripts in `bin/` are linted with shellcheck (`.github/workflows/tests.yml`) —
  keep new scripts shellcheck-clean, or add them to the `ignore_names` list only if
  they're not real shell (e.g. `icalBuddy`).
- No secrets in this repo — it's public. Machine-specific values (emails, hostnames)
  go through `dotfiles.yml` role vars or `group_vars/`, not hardcoded in role files.

## Testing a change

There's no full local dry-run; the practical loop is:
1. `bash bin/doi -t <the-tag-you-changed>` on your actual machine.
2. `make ci` (runs the GitHub Actions workflow via `act`) for the shellcheck/bootstrap
   checks, or push and let `.github/workflows/tests.yml` run on macOS + Ubuntu runners.
