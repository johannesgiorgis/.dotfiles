# Repo Health Audit — 2026-08-25

Comprehensive sweep of `.dotfiles` while setting up a new MacBook, covering correctness,
idempotency, deprecations, security, and maintainability across the macOS and
Debian/Pop!_OS targets. Produced by six parallel research passes (Ansible correctness,
security, asdf/version-managers, macOS/Homebrew, Linux/Pop!_OS, CI/tooling) plus manual
verification of the highest-severity claims.

Every finding below cites a real `file:line` that was actually read, or a WebSearch
source for external facts (package status, deprecations, tool versions). Nothing here is
speculative.

This doc is the **living tracker** for this work, not a one-time report — it's meant to
be picked up across many separate Claude Code sessions on this repo, worked through
incrementally.

## How to use this doc

1. Read the **Status** table below (Severity, Needs, current Status).
2. Pick the next `Open` (or `Partial`) row whose **Needs** matches what you have right
   now — `either`, or the OS you're actually on. Skip rows needing Linux if you're on
   macOS, and vice versa.
3. Implement the fix. Verify it as concretely as you can — run the actual role/task,
   check real output, don't just eyeball the diff.
4. Update **two** places: the table row's Status cell, and that finding's own section
   further down with a short "✅ Resolved `<date>`" note (what changed, how it was
   verified). Nothing gets deleted — mark resolved, keep the original finding as the
   record of what was wrong. Add one line to the **Change log** at the bottom.
5. If something's a genuine open decision rather than a bug (architecture calls like
   COSMIC vs. GNOME, asdf vs. mise) — don't guess. Either ask, or drop it in
   **Notes / open questions** below and move to the next row.

Status markers, used throughout:
- ✅ **Resolved** — fixed and verified
- ⚠️ **Partial** — some of it done, rest genuinely blocked or deferred (with the reason)
- ⏭️ **Skipped** — deliberately deferred (with the reason)
- ❎ **Not an issue** — reviewed and intentionally declined, with the reasoning (this is
  feedback from the repo owner overriding the original finding, not an "oops, ignore it")
- *(no marker / "Open")* — still open

---

## Status

**At a glance:** 13 resolved, 2 partial, 1 skipped, 1 not-an-issue, 12 open (29 total;
#20/#21/#22/#23/#24/#25 were all caught live during this session's own work — CI and
real reported bugs — not the original 6-agent audit sweep; #26–#29 came from diffing a
work MacBook Pro 16 software snapshot against the roles) — of the 12 open, 2 are gated
on having a Linux/Pop!_OS box (`#4`, `#5`); the rest are actionable right now regardless
of which machine you're on.

| # | Finding | Severity | Domain | Effort | Needs | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | asdf v0.16 syntax break (6 roles + install role) | Critical — live outage | Ansible/asdf | Low (patch) / Med (mise migration) | — | ✅ Resolved 2026-08-25 |
| 2 | `bin/doi` fails to bootstrap on Ubuntu/Pop!_OS 24.04 (noble) | Critical — live outage | Tooling | Low | Linux | ⏭️ Skipped (macOS-only setup) |
| 3 | `dotfiles.yml:54` missing colon on `when:` | High | Ansible | Trivial | — | ✅ Resolved 2026-08-25 |
| 4 | Pop!_OS COSMIC breaks GNOME-targeting roles | Critical — strategic | Linux | High (rewrite) | Linux + decision | Open |
| 5 | `gnome-shell-extension-tool` removed from GNOME | High | Linux | Trivial | Linux | Open |
| 6 | `authy` cask installs EOL'd app | High | macOS | Trivial | — | ✅ Resolved 2026-08-25 |
| 7 | `failed_when` type-mismatch, 6 roles | High | Ansible | Low | — | ✅ Resolved 2026-08-25 |
| 8 | `apt_key`/`apt_repository` deprecated, 13 files/18 sites | High | Ansible/deprecation | Medium (mechanical) | Linux (remainder) | ⚠️ Partial 2026-08-25 — 7/11 files done, 4 PPA-based files open |
| 9 | `state: latest`, 12 locations | High → n/a | Ansible | — | — | ❎ Not an issue (repo owner call, 2026-08-25) |
| 10 | Unpinned remote-installer scripts, 4 roles | Medium | Security | Low (document) | either | Open |
| 11 | `apt-key add` over-broad trust (docker) | Medium | Security | Resolved by #8 | — | ✅ Resolved 2026-08-25 |
| 12 | No collections `requirements.yml`/`ansible.cfg` | High | Ansible/reproducibility | Low | — | ✅ Resolved 2026-08-25 |
| 13 | CI covers 2/88 roles; ansible-lint installed but unused | High | CI | Low | either | ⚠️ Partial 2026-08-25 — ansible-lint+syntax-check now run in CI on all 88 roles statically; functional smoke-test coverage still 2/88 |
| 14 | `docker/Dockerfile` pinned to EOL `ubuntu:18.04` | Medium | CI | Low | either | Open |
| 15 | GitHub Actions on mutable refs (`@main`/`@master`/old `@v3`) | Low-Medium | Security/CI | Low | either | ✅ Resolved 2026-08-25 |
| 16 | ~60 shell/command tasks missing idempotency guards | Medium | Ansible | Medium | either | Open |
| 17 | `sshd_config` mode typo (`06444`) | Low | Security | Trivial | either | Open |
| 18 | Stale docs/README references (branch, tagging, dead Makefile target) | Low | Maintainability | Low | either | Open |
| 19 | Cross-platform stubs (granted/craftnotes/notesnook/box-drive Linux TODO) | Low | Cohesion | Medium | Linux + decision | Open |
| 20 | `bin/gico` unquoted `git clone $var` (SC2086) + SC2001 style hit | Low | Shell/correctness | Trivial | — | ✅ Resolved 2026-08-25 |
| 21 | `taskd` Homebrew formula removed upstream, `taskwarrior` role installs it unconditionally | High | macOS | Trivial | — | ✅ Resolved 2026-08-25 |
| 22 | `zsh` role: dead `homebrew_tap` task, unprotected `block`, cascaded into a broken live shell | High | Ansible/zsh | Low | — | ✅ Resolved 2026-08-25 |
| 23 | Dead/never-existed oh-my-zsh plugin entries: `fd`, `ripgrep`, `timewarrior` | Low | Shell/maintainability | Trivial | — | ✅ Resolved 2026-08-25 |
| 24 | `common-cli` role: dead `neofetch` Homebrew formula (unprotected block) silently killed every later task — `act`/`broot`/`coreutils`/`eza`/`sd`/`wifi-password`/`zoxide`/`noti`/`uv` all went uninstalled | High | Ansible/macOS | Trivial | — | ✅ Resolved 2026-08-30 |
| 25 | `youtube-dl` role installs a Homebrew formula removed from homebrew-core upstream | Medium | macOS | Trivial | — | ✅ Resolved 2026-08-30 |
| 26 | Jira/Atlassian CLI (`acli`) installed manually on work machine, no role captures it | Low | Software inventory | Low | macOS | Open |
| 27 | Work-machine CLI tools & Mac App Store apps installed but never added to roles | Low | Software inventory | Medium | macOS | Open |
| 28 | Homebrew casks installed but uncaptured, incl. `iterm2` (the actual terminal) with zero role | Low | Software inventory | Medium | macOS | Open |
| 29 | `flux` role installs cask `flux`; this machine actually has `flux-app` (upstream rename) | Low | macOS/Homebrew | Trivial | macOS | Open |

Detailed writeup for every row lives in the numbered sections below (§1–§8) — jump to §1
"Ansible correctness & idempotency" for the Ansible-domain rows, §2 "Deprecations" for
rows 4/5/8, §4 "macOS/Homebrew" for row 6, §5 "Security" for rows 10/11/15/17, §6
"CI, tooling & maintainability" for rows 2/13/14/18, §7 "Zsh / shell configuration"
for rows 22/23, and §8 "Software inventory gaps" for rows 26–29.

## Next steps (suggested order)

1. **Anything still blocking a real setup run**: #1 and #3 are done; #2 remains skipped
   (needs Linux).
1. ✅ **Done 2026-08-25 — cheap, high-leverage guardrail**: `ansible-lint` +
   `--syntax-check` now run in CI (#13) — the bug classes behind #3 and #7 get caught
   automatically going forward.
1. **Finish the mechanical migration**: `apt_key`/`apt_repository` → `deb822_repository`
   for the 4 remaining PPA-based files (#8 remainder) — needs real per-PPA key lookups,
   ideally verified on Linux.
1. **Cleanup pass**: `gnome-shell-extension-tool` fix (#5, needs Linux). (#9 closed as
   not-an-issue, see below — no action needed.)
1. **Decide, don't just patch**: Pop!_OS/COSMIC (#4) and asdf-vs-mise are real
   architectural questions, not line fixes — see Notes below.
1. **Remaining CI/reproducibility loose ends**: #12's `requirements.yml` wiring is
   ✅ done 2026-08-25 (`bin/doi`'s remaining) — expand functional smoke-test coverage
   past `taskwarrior`/`zsh` (#13 remainder), add an `ansible.cfg` (#12 remainder), and
   update `docker/Dockerfile`'s EOL base image (#14).

## Notes / open questions

Loose threads that aren't clean findings — context for whoever (human or Claude) picks
this up next:

- **Decision needed:** is the actual target Pop!_OS machine running COSMIC or the legacy
  GNOME session? This determines whether #4/#5/#19 and the `linux-gnome-*`/
  `linux-dconf-settings` roles are still relevant as-is or need a real rewrite. See §2.3.
- **Decision needed, non-urgent:** stay on asdf (patched, done 2026-08-25) or migrate to
  `mise`? Currently staying on asdf — see §3's recommendation for the tradeoff.
- **PPA key lookups owed** for §2.1's remaining 4 files (`audacity`,
  `linux-conky-manager` ×2, `linux-kazam`, `obs-studio`) — need each PPA's real
  `ppa.launchpadcontent.net` URL and GPG key fingerprint before migrating off
  `apt_repository`. Don't guess these.
- **Unverified on real Linux hardware:** the docker `deb822_repository` migration (§2.1)
  and the asdf Debian install path (§3, `get_url`/`unarchive` fallback in
  `roles/infrastructure/asdf/tasks/main.yml`) both only passed `--syntax-check` +
  `ansible-lint` on this macOS machine — re-verify for real (`bash bin/doi -t docker`,
  `bash bin/doi -t asdf`) the next time there's a Linux box available.
- **When to consolidate CI onto a local `make` target — the rule that came out of
  [§6.7](#sec-6-7):** worth it when CI is slow/heavy, or when you want pre-commit-style
  local checks; not worth it just because a marketplace action's config could
  theoretically drift from a local script. Applied: reverted the shellcheck job back to
  `ludeeus/action-shellcheck` (cheap, fast, no real local-loop benefit); kept/added it for
  `ansible-lint` via `make lint` (CI pip-installs ansible from scratch every run — a real
  cost the local machine doesn't pay since it's already installed).
- **Filename convention:** this doc is date-prefixed (`2026-08-25-...`) per this repo's
  existing `docs/` convention for point-in-time docs, even though it's actually a living
  tracker that'll get edited over weeks — deliberately not renaming it now (2026-08-25
  conversation: keep the date, it marks when this effort started; revisit later based on
  how it actually ends up getting used).

---

**Change log**
- 2026-08-25: asdf v0.16 command-syntax break fixed in all 6 language roles + the asdf
  install role itself (switched to `homebrew` on macOS), and the `failed_when`
  type-mismatch in those same 6 roles fixed alongside it. Verified live on this machine
  (`bash bin/doi -t asdf`, confirmed `asdf plugin add`/`asdf set --home` work against the
  installed 0.20.0). See [§3](#sec-3), [§1.2](#sec-1-2). The `bin/doi` Ubuntu/Pop!_OS
  bootstrap fix ([§6.1](#sec-6-1)) was explicitly skipped for now — current setup is
  macOS-only.
- 2026-08-25: `dotfiles.yml`'s missing `when:` colon fixed ([§1.1](#sec-1-1)), and the
  `authy` role (dead app, Twilio EOL'd it in 2024) removed entirely ([§4](#sec-4)). The
  two GNOME/Pop!_OS findings ([§2.2](#sec-2-2), [§2.3](#sec-2-3)) remain open and
  untestable for now — no Linux box available to verify against.
- 2026-08-25: `apt_key`/`apt_repository` → `deb822_repository` migrated for the 7 files
  using a static repo URL + key URL (`docker`, `brave-browser`, `plex`, `spotify`,
  `sublime-merge`, `sublime-text`, `vscode`) — also removed the dead docker `apt-key add`
  task ([§1.3](#sec-1-3)) and closed the over-broad-trust security finding
  ([§5.2](#sec-5-2)) as a side effect. The 4 PPA-based files (`audacity`,
  `linux-conky-manager` ×2, `linux-kazam`, `obs-studio`) were deliberately left alone —
  `deb822_repository` doesn't resolve PPA shorthand, so migrating those needs real
  per-PPA key lookups rather than a mechanical swap. See [§2.1](#sec-2-1).
- 2026-08-25: restructured this doc for cross-session use — moved Status table and next
  steps to the top (was buried at the bottom as §7), added a Needs column (macOS/Linux/
  either/decision) so a session can filter to what's actionable on whatever machine it's
  on, added the "How to use this doc" protocol and this Notes section, and moved the
  change log below Notes, ahead of the detailed findings (§1–§6) rather than being the
  very first thing in the file. No findings content changed, only reorganized.
- 2026-08-25: added an `ansible-lint`/`--syntax-check` job to CI ([§6.4](#sec-6-4)),
  using the `min` profile deliberately (repo-wide FQCN/style debt would fail the default
  profile immediately). Required creating `requirements.yml` (pins `community.general`)
  so the collection resolves in a clean CI environment — partially resolves
  [§1.7](#sec-1-7)/#12, though `bin/doi`'s local bootstrap doesn't consume it yet.
  Extended the workflow's `push.paths` filter to actually include `roles/**`/
  `dotfiles.yml`/`group_vars/**` (previously a direct push to `main` touching a role
  wouldn't trigger CI at all). Also pinned all GitHub Actions to real versions
  ([§5.5](#sec-5-5)) and added a `permissions: contents: read` block ([§5.6](#sec-5-6)).
- 2026-08-30: diffing a fresh MacBook Air 13 setup against a MacBook Pro 16 install
  snapshot turned up two more dead-upstream-formula bugs, same shape as #21/#22:
  `common-cli`'s `neofetch` (formula removed from homebrew-core, and being early in an
  unprotected block's loop meant its failure silently killed every later task in that
  role — `eza`/`coreutils`/`zoxide`/`broot`/`act`/`sd`/`wifi-password`/`noti`/`uv` all
  went uninstalled) and `youtube-dl`'s own formula (also removed upstream). Fixed by
  swapping to the actively-maintained successors, `fastfetch` and `yt-dlp` respectively.
  Both verified live and fully resolved (`bash bin/doi -t common-cli` and
  `-t youtube-dl`, `failed=0` on each). See [§4](#sec-4).
  Verified by running the exact same steps in a clean local venv before writing the
  workflow file — both syntax-check and lint passed clean.
- 2026-08-25: `state: latest` (#9, [§1.4](#sec-1-4)) closed as **not an issue** on repo
  owner feedback — idempotency here means "the right tool is present," not "the version
  never changes"; that's already handled explicitly for languages/frameworks via asdf.
  Left `virtualbox` flagged as the one package worth watching if a rerun ever behaves
  unexpectedly, not because it's currently broken.
- 2026-08-25: wired `requirements.yml` into `bin/doi`'s local bootstrap (#12
  [§1.7](#sec-1-7)) — new `ensure_collections_are_present()`, called unconditionally on
  every run so a local machine's collections stay in sync with the same pin CI checks,
  not just on first install. Removed the old ad-hoc unpinned collection install that only
  ran on fresh Debian `focal` machines. Verified live on this box. `ansible.cfg` is the
  only piece of #12 still open.
- 2026-08-25: first real CI run after pinning `action-shellcheck` and extending trigger
  paths turned up two genuinely new bugs the original 6-agent audit sweep missed — added
  as #20 and #21. **#20** ([§6.6](#sec-6-6)): `bin/gico` had real shellcheck findings
  (SC2086 unquoted `git clone $var`, SC2001 style) — fixed and verified by reproducing
  the action's exact file-scan logic locally, not just running shellcheck blind (which
  gave a misleading result pointing at unrelated `.py` files never actually in scope).
  **#21** ([§4](#sec-4)): the `taskwarrior` role's homebrew install list includes `taskd`,
  a formula removed from homebrew-core upstream — caught by the `tests (macos-latest)`
  job, the one piece of functional CI coverage this repo has. Fixed by dropping `taskd`;
  verified live. Investigated with `gh` (user ran `gh auth login` mid-session) to pull
  real job logs rather than guessing from the API's limited public annotations — also
  ruled out a red herring (`aws/tap` Homebrew tap-trust warning in the same log) as
  unrelated noise, not the actual cause.
- 2026-08-25: added `bin/shellcheck-local.sh` + `make shellcheck` so shellcheck is easy
  to run locally, then consolidated on repo owner's suggestion — CI's `shellcheck` job
  now runs that same `make shellcheck` instead of a separately-configured marketplace
  action ([§6.7](#sec-6-7)), removing `ludeeus/action-shellcheck` entirely and leaving a
  single source of truth for file-selection/ignore logic. Caught and fixed a real
  BSD-vs-GNU `find -perm` portability bug in the script itself before it ever reached CI.
- 2026-08-25: reverted the shellcheck consolidation the same day it landed, after
  thinking it through out loud — the job is cheap/fast (~1s) and push-and-check is
  already as fast as running it locally, so there was no real benefit to offset the cost
  of owning file-discovery logic ourselves. `bin/shellcheck-local.sh` removed;
  `ludeeus/action-shellcheck@2.0.0` restored. See [§6.7](#sec-6-7) for the rule this
  produced (consolidate when CI is slow/heavy or you want pre-commit checks, not by
  default). Applied that rule to `ansible-lint` instead, where it actually fits — added
  `make lint` (`ansible-galaxy collection install` + `--syntax-check` +
  `ansible-lint --profile min`) and pointed the CI job at it. Unlike shellcheck, that job
  genuinely does real setup work (pip-installs `ansible`+`ansible-lint` from scratch every
  run) that the local machine skips entirely (already installed via `bin/doi`), so the
  round-trip savings are real here. Verified locally: `make lint` passes clean.
- 2026-08-25: closed out #12 ([§1.7](#sec-1-7)) — added `ansible.cfg` (`inventory`,
  `roles_path`, `collections_path`, `retry_files_enabled`). Discovered along the way that
  an untracked `.ansible/` directory had appeared at the repo root — `ansible-lint`'s own
  dependency resolver, auto-installing collections into a project-local cache from
  `requirements.yml`. Added it to `.gitignore` (derived/reproducible, not source) and
  pointed the new `collections_path` at that same location so `ansible-galaxy`/
  `ansible-playbook` are now consistent with what `ansible-lint` had already independently
  chosen. Deliberately left `deprecation_warnings` at its default (shown) — those warnings
  are the live signal for §2.1's remaining migration work, not noise to suppress. Verified
  live: `ansible-config dump` confirms all four settings load from the new file; syntax
  check, lint, and `bin/doi` all still pass using the new defaults (no more relying on
  every caller passing `-i hosts` explicitly).
- 2026-08-25: new §7 added for two zsh findings that came from a real bug report rather
  than the original audit sweep. **#22**: root-caused actual reported crashes (process
  substitution failures, a zsh malloc corruption crash, missing rust completions) to the
  `zsh` role's `homebrew_tap: homebrew/command-not-found` task — a tap Homebrew
  permanently deprecated — sitting in an unprotected `block:` *before* the task that
  creates `~/zsh/cache/completions`; its failure silently aborted the rest of the play.
  Deleted the dead task (confirmed unnecessary too — Homebrew moved command-not-found
  into brew core itself), reordered the directory-creation task earlier, and added a
  defensive `mkdir -p` directly in `.zshrc` so the shell self-heals regardless of ansible
  run state. Verified live — repo owner re-ran the role for real (needed interactively
  for an unrelated sudo prompt) and confirmed the crashes are gone. **#23**: traced
  `fd`/`ripgrep` oh-my-zsh plugin entries through the vendored checkout's actual git
  history — both were real plugins, removed by upstream 2026-07-23 as a breaking change
  once package managers started bundling completions directly; `timewarrior` never
  existed at all. Repo owner commented out the dead entries. Full audit of the rest of
  the plugin list found nothing else needing attention.
- 2026-09-01: captured a software snapshot of a second machine, a work MacBook Pro 16 —
  `docs/2026-09-01-work-macbookpro16-installed-apps.txt` — and diffed
  `brew leaves -r`/`brew list --cask`/`mas list` against every role and
  `group_vars/all/mas.yml`. New §8 added with 4 findings (#26–#29): the
  Jira/Atlassian CLI (`acli`) is installed but has no role; several CLI tools
  (`ansible-lint`, `yamllint`, `bfg`, `git-secrets`, `pnpm`, `postgresql@14`,
  `subversion`, `mypy`) and 7 Mac App Store apps are installed but uncaptured; several
  Homebrew casks are uncaptured, notably `iterm2` (the actual terminal) having zero
  role; and the `flux` role's cask name (`flux`) has drifted from what's actually
  installed (`flux-app`), same shape as the neofetch/youtube-dl formula-rename bugs
  (#24/#25). None of these are bugs against this repo's actual goal (capturing the
  journey, not 100% reproducibility) — left as Open, prioritization is the repo owner's
  call.

---

## 1. Ansible correctness & idempotency

<a id="sec-1-1"></a>
### 1.1 `dotfiles.yml`: broken `when:` clause

✅ **Resolved 2026-08-25** — colon added, confirmed in `dotfiles.yml` (now
`when: ansible_os_family == "Darwin"`).

`dotfiles.yml:54`:
```yaml
- {
    role: infrastructure/macos-initial-configuration,
    tags: [macos-initial-configuration],
    when ansible_os_family == "Darwin",   # <- missing colon after `when`
  }
```
YAML parses this as a bogus dict key, not a `when:` condition. Verified with
`ansible-playbook dotfiles.yml -i hosts --list-tasks --tags macos-initial-configuration`:
the role is completely ungated. On Linux this role still runs — creating
`~/Library/LaunchAgents` and attempting macOS-only keyboard-remapping tasks.

**Fix:** add the colon.

<a id="sec-1-2"></a>
### 1.2 `failed_when` type-mismatch, repeated across 6 roles

✅ **Resolved 2026-08-25** — dropped the broken `failed_when` line in all six roles
(restores Ansible's default fail-on-nonzero-rc), fixed in the same pass as the asdf
v0.16 syntax break in [§3](#sec-3). Left below for the record of what was wrong.

Every asdf-plugin language role registers the `plugin-add` result and then compares the
*whole result object* to an integer — always `False`, which silently disables Ansible's
default fail-on-nonzero-rc behavior for that task:

| File | Line | Code |
| --- | --- | --- |
| `roles/infrastructure/terraform/tasks/main.yml` | 25 | `failed_when: terraform_add == 1` |
| `roles/infrastructure/python/tasks/main.yml` | 46 | `failed_when: python_add == 1` |
| `roles/infrastructure/deno/tasks/main.yml` | 46 | `failed_when: deno_add == 2` |
| `roles/infrastructure/nodejs/tasks/main.yml` | 41 | `failed_when: nodejs_add == 2` |
| `roles/infrastructure/golang/tasks/main.yml` | 23 | `failed_when: golang_add == 2` |
| `roles/infrastructure/gohugo/tasks/main.yml` | 20 | `failed_when: gohugo_add == 2` |

**Fix:** compare the actual field, e.g. `failed_when: terraform_add.rc not in [0, 2]`
(confirm the real "plugin already exists" rc first), or delete `failed_when` entirely to
restore default rc-based failure detection. These same six call sites also need the
asdf v0.16 command-syntax fix — see [§3](#sec-3) — do both in
the same pass since they're adjacent lines.

<a id="sec-1-3"></a>
### 1.3 Dead, misleadingly-named task in the docker role

✅ **Resolved 2026-08-25** — removed as part of the [§2.1](#sec-2-1) `deb822_repository`
migration; the whole get_url-key + `apt-key add` + `apt_repository` dance was replaced
by one `deb822_repository` task whose `signed_by` handles the key.

`roles/infrastructure/docker/tasks/debian.yml:43-45`, named "Add Docker repository" but
doesn't — it's `curl -sSL {{ docker_apt_gpg_key }} | apt-key add -`, redundant with the
`get_url` task immediately above (which already places the key correctly via
`/etc/apt/trusted.gpg.d/docker.asc`). It also shells out to the `apt-key` binary, which
is removed outright on modern Debian/Ubuntu, independent of the Ansible module
deprecation. **Fix:** delete this task.

<a id="sec-1-4"></a>
### 1.4 `state: latest` — ❎ not an issue

❎ **Not an issue — repo owner call, 2026-08-25.** The definition of "idempotent" this
repo actually cares about is *the right tool is installed*, not *the exact version never
changes*. Anything that genuinely needs version control — languages/frameworks — already
gets it explicitly via asdf's `*_versions` lists (see [§3](#sec-3)), independent of this
finding. For everything below, always-tracking-latest is the intended behavior, not a
bug. No fix needed.

One thing worth actually watching, not because it's broken now but because it's the kind
of package where a `state: latest` auto-upgrade could bite: **`virtualbox`**
(`roles/software/virtualbox/tasks/main.yml:12`) — a major-version bump to virtualization
software can occasionally require reconfiguring or fail to boot existing VMs (see the
Apple-Silicon caveat already noted in [§4](#sec-4)). Not a change to make now, just
something to notice if a `bash bin/doi -t virtualbox` rerun ever does something
surprising. Everything else in the list below (`vim`, `common-cli` tools, `youtube-dl`,
`taskwarrior`, `google-chrome`, `sqlite-browser`, `meld`, `linux-openssh`) is a plain
utility or a security-patched daemon where always-latest is straightforwardly desirable.

Original finding, kept for the record: all on `apt:` tasks (no `homebrew`/`pip`/`npm`
instances found) —
`roles/cli/vim/tasks/main.yml:17`, `roles/cli/common-cli/tasks/main.yml:11,20,38`,
`roles/cli/youtube-dl/tasks/main.yml:12,30,35`, `roles/cli/taskwarrior/tasks/main.yml:12`,
`roles/software/google-chrome/tasks/main.yml:12`,
`roles/software/sqlite-browser/tasks/main.yml:12`,
`roles/software/virtualbox/tasks/main.yml:12`, `roles/software/meld/tasks/main.yml:12`,
`roles/infrastructure/linux-openssh/tasks/main.yml:11`.

### 1.5 Idempotency guards missing on ~60 shell/command tasks
Only a handful of roles follow the good check-then-install pattern — use these as the
house reference: `roles/cli/claude-code/tasks/main.yml:4-7`,
`roles/cli/common-cli/tasks/uv.yml:5-8`, `roles/infrastructure/rust/tasks/main.yml:22-24`,
`roles/infrastructure/ollama/tasks/main.yml:8-11`, and especially
`roles/infrastructure/linux-lightdm/tasks/configure.yml:20-24` (a genuinely well-built
idempotent version-check).

Everything else re-executes and reports "changed" every run, even when nothing changed:

- **GitHub-API "latest version" lookups with no cache/guard**, burning unauthenticated
  API rate-limit quota on every playbook run for no benefit:
  `roles/cli/common-cli/tasks/jump.yml:17-20`, `roles/cli/common-cli/tasks/noti.yml:22-25`,
  `roles/software/rambox/tasks/main.yml:16-19`, `roles/infrastructure/asdf/tasks/main.yml:5-8`,
  `roles/infrastructure/docker/tasks/install-docker-compose.yml:7-10`.
- **`asdf install`/`asdf global` loops** (terraform, deno, nodejs, python, golang, gohugo —
  the tasks right after the `plugin-add` ones) have no `changed_when`, so they report
  changed even when the version is already installed and set as global.
- **`roles/software/vscode/tasks/install-extensions.yml:3` and the vscodium equivalent**:
  `command: '{{ visual_studio_code_exe }} --install-extension {{ item }}'` — no guard,
  reinstalls every extension every run.
- **`roles/infrastructure/awscli/tasks/main.yml:21-23`**: downloads and installs the AWS
  CLI unconditionally every run. There's a `which aws` check registered nearby but it's
  never actually used to skip the install — dead check.

### 1.6 Minor cleanup
- `roles/infrastructure/awscli/tasks/main.yml:13,22-23` — block already has
  `become: "{{ should_be_root }}"`, but the shell command inside also hardcodes `sudo` —
  redundant, pick one.
- `roles/cli/vim/tasks/main.yml:25` — `failed_when: False` is dead code (`stat` never
  fails on a missing path); safe to delete. Contrast with
  `linux-lightdm/tasks/configure.yml:23-24`'s `changed_when: False` + `failed_when: False`
  on a version-probe of a possibly-not-yet-installed package, which *is* correct —
  don't touch that one.

<a id="sec-1-7"></a>
### 1.7 Reproducibility gap: no pinned collections

✅ **Resolved 2026-08-25** — added `requirements.yml` at repo root, pinning
`community.general: ">=13.3.0,<14.0.0"`; the CI lint job ([§6.4](#sec-6-4)) installs from
it. As of 2026-08-25, `bin/doi` does too: added `ensure_collections_are_present()`
(`bin/doi`), called unconditionally in `main()` right after `ensure_ansible_is_present`
— so it runs on every invocation, not just a fresh install, keeping the local machine's
collections in sync with the same pin CI checks against. Also removed the old
`install_ansible_base_and_collections_on_debian`'s ad-hoc, unpinned, Debian-`focal`-only
`ansible-galaxy collection install community.general` call (renamed to
`install_ansible_base_on_debian`) — it was redundant with, and inconsistent with, the new
unconditional step. Verified live: `bash bin/doi -f <nonexistent-tag>` (safe no-op path
that still runs bootstrap) correctly resolved `requirements.yml` via `$ANSIBLE_DIR` and
reported the pinned collection already satisfied. `shellcheck bin/doi` clean.

**Closed out 2026-08-25:** added `ansible.cfg` at repo root —
`inventory = hosts`, `roles_path = roles`, `collections_path = .ansible/collections`
(repo-local, gitignored — matches the location `ansible-lint`'s own resolver had already
independently chosen, discovered while investigating the untracked `.ansible/` directory;
now `ansible-galaxy`/`ansible-playbook` are consistent with it instead of defaulting to
`~/.ansible/collections`), `retry_files_enabled = False` (stops a failed play from
dropping a `dotfiles.yml.retry` file into the repo root). Deliberately did **not** set
`deprecation_warnings = False`, even though every `--syntax-check` run suggests it —
those warnings are the live signal for [§2.1](#sec-2-1)'s remaining
`apt_repository` → `deb822_repository` migration; silencing them would hide exactly the
thing still tracked as open.

Verified live: `ansible-config dump --only-changed` shows all four settings picked up
from `ansible.cfg`; `ansible-playbook dotfiles.yml --syntax-check` (no `-i` flag) and
`ansible-lint --profile min dotfiles.yml` (no flags) both still pass clean using the new
defaults instead of relying on `bin/doi`/CI always passing `-i hosts` explicitly;
`bash bin/doi -f <nonexistent-tag>` still runs cleanly end to end.

`homebrew`, `homebrew_cask`, `mas`, `cargo`, and `github_release` all resolve to
`community.general` modules (confirmed via `ansible-doc`; currently v13.3.0 on this
machine), and nothing in the repo — no `requirements.yml`, no `ansible.cfg` — pins that
version. A fresh machine set up months from now gets whatever `brew install ansible`
happens to bundle that week. Given the repo's whole reason for existing (idempotent,
reproducible setup), this is the single highest-leverage reproducibility gap: two
machines set up months apart can silently diverge in module behavior with no visibility
into why.

**Fix:** add a `collections/requirements.yml` pinning `community.general` to a known-good
version, and an `ansible.cfg` declaring `collections_path`, `roles_path`, and
`inventory = hosts` explicitly rather than relying on ambient CLI flags.

Related: module naming is inconsistent throughout (bare `apt`, `homebrew`, `command`,
`shell`, `file` vs FQCN `ansible.builtin.shell`, `community.general.mas`). Not a bug by
itself, but combined with the missing pin above, standardizing on FQCN everywhere would
make it obvious at a glance which modules come from an unpinned external collection.

---

## 2. Deprecations requiring migration

<a id="sec-2-1"></a>
### 2.1 `apt_key` / `apt_repository` → `deb822_repository`

✅ **Partially resolved 2026-08-25** — migrated the 7 files below that use a static repo
URL + key URL (clean 1:1 swap to `deb822_repository`, `signed_by` given the key URL
directly instead of a separate fetch-and-trust step): `docker` (also removed the dead
`apt-key add` task, see [§1.3](#sec-1-3), and resolves [§5.2](#sec-5-2)), `brave-browser`,
`plex`, `spotify`, `sublime-merge`, `sublime-text`, `vscode`. Verified with
`ansible-playbook --syntax-check` (deprecation warnings for these 7 are gone) and
`ansible-lint` (no module-arg errors on the new tasks) — not live-tested on Debian/Linux.

**Still open, and NOT the same mechanical pattern** — `audacity`, `linux-conky-manager`
(×2), `linux-kazam`, `obs-studio` all add a repo via **PPA shorthand**
(`apt_repository: repo: ppa:owner/name`), not a static deb line + key URL. They have no
`apt_key` task at all — `apt_repository`'s PPA handling auto-resolves the real repo URL
and imports the signing key for you; `deb822_repository` has no PPA support, so migrating
these means manually looking up each PPA's actual `ppa.launchpadcontent.net` URL and GPG
key fingerprint per-PPA. Doing that blind risks a wrong/insecure key config — didn't want
to guess. Leave on `apt_repository` for now (still functional, just deprecated, until
ansible-core 2.25) and revisit with real lookups, ideally with a Linux box to verify
against.

Ansible itself surfaces this on every `--syntax-check` run:
> `[DEPRECATION WARNING]: apt_repository has been deprecated. Use deb822_repository
> instead. This feature will be removed from ansible-core version 2.25.`

`deb822_repository` is `ansible.builtin` (ansible-core, not a collection), added in
**ansible-core 2.15** — already available on this machine's ansible-core 2.21, so this is
a pure migration, not a version blocker.

**Full inventory — 13 files, 18 call sites**, all doing apt-repo-management:

| File | Lines |
| --- | --- |
| `roles/infrastructure/docker/tasks/debian.yml` | 48 |
| `roles/software/audacity/tasks/main.yml` | 8 |
| `roles/software/brave-browser/tasks/main.yml` | 17, 23 |
| `roles/software/linux-conky-manager/tasks/main.yml` | 7, 14 |
| `roles/software/linux-kazam/tasks/main.yml` | 9 |
| `roles/software/obs-studio/tasks/main.yml` | 16 |
| `roles/software/plex/tasks/main.yml` | 20, 25 |
| `roles/software/spotify/tasks/main.yml` | 16, 22 |
| `roles/software/sublime-merge/tasks/main.yml` | 16, 27 |
| `roles/software/sublime-text/tasks/debian.yml` | 7, 18 |
| `roles/software/vscode/tasks/debian.yml` | 13, 18 |

Before/after (same shape applies to all of the above):
```yaml
# before
- apt_key: {url: "{{ sublime_apt_key }}", state: present}
- apt_repository: {repo: "deb https://download.sublimetext.com/ apt/stable/", state: present}

# after
- ansible.builtin.deb822_repository:
    name: sublime-text
    types: deb
    uris: https://download.sublimetext.com/
    suites: apt/stable/
    signed_by: "{{ sublime_apt_key }}"
    state: present
```
This is one mechanical pattern repeated 11 times — a good candidate for a single focused
PR. It also resolves the security concern in [§5.2](#sec-5-2).

<a id="sec-2-2"></a>
### 2.2 `gnome-shell-extension-tool` is gone
`roles/infrastructure/linux-gnome-extensions/tasks/install_extension.yml:38` uses
`gnome-shell-extension-tool --enable-extension`. This binary was removed from GNOME Shell
3.34+ (2019) in favor of `gnome-extensions enable <uuid>`. On any GNOME version from the
last ~6 years, the command doesn't exist — the role silently fails to enable extensions
it just installed.

**Fix:** `command: gnome-extensions enable {{ gnome_extension_info.uuid }}`. Do this
regardless of the COSMIC question below — it's broken even on a legacy-GNOME session.

<a id="sec-2-3"></a>
### 2.3 Strategic: Pop!_OS has moved to COSMIC desktop
Verified via WebSearch: **Pop!_OS 24.04 LTS shipped stable in late 2025 with COSMIC
(System76's own Rust-based desktop) as the default**, replacing the GNOME-based session
this repo was written for. Sources:
[System76 blog](https://blog.system76.com/post/pop-os-letter-from-our-founder/),
[COSMIC desktop — Wikipedia](https://en.wikipedia.org/wiki/COSMIC_desktop),
[alternativeto.net coverage](https://alternativeto.net/news/2025/12/system76-launches-first-stable-versions-of-pop-_os-24-04-lts-and-cosmic-desktop).

COSMIC doesn't use GNOME Shell, GNOME Shell extensions, or gsettings/dconf schemas for
its own shell chrome. This makes the following **partially or fully non-functional** on
any machine actually running COSMIC rather than a legacy GNOME session:

- `roles/infrastructure/linux-gnome-extensions` (entire role — no such concept in COSMIC)
- `roles/infrastructure/linux-gnome-tweaks` (GNOME Tweaks doesn't apply to COSMIC)
- Most of `roles/infrastructure/linux-dconf-settings` (`/org/gnome/desktop/*`,
  `/org/gnome/settings-daemon/*` keys)
- `roles/infrastructure/popos-initial-configuration`'s
  `gsettings set org.gnome.desktop.wm.preferences button-layout`

This is the same class of problem as the asdf breakage below — not a line fix, a real
rewrite, because COSMIC uses its own config system rather than dconf. **Recommendation:**
decide whether your Pop!_OS machines are actually running COSMIC or the legacy GNOME
session before touching these roles — if COSMIC, budget this as a separate, deliberate
piece of work (COSMIC-native config equivalents), not a quick patch.

Related, smaller: `roles/infrastructure/linux-lightdm/files/install-lightdm-webkit2-greeter.sh`
adds a repo for Debian 9 "Stretch" (EOL 2020) from an abandoned personal OBS repo for the
discontinued Antergos distro — will very likely 404. COSMIC ships its own greeter
(`cosmic-greeter`, greetd-based), making lightdm-webkit2-greeter theming moot on COSMIC
machines anyway. Recommend retiring this script rather than patching it.

Lower-priority strategic notes from the same pass: Snap vs Flatpak momentum has shifted
further toward Flatpak in the broader Linux desktop ecosystem by 2026 — not a functional
break for `linux-snap`, just worth knowing if you're picking a universal package format
going forward.

---

<a id="sec-3"></a>
## 3. asdf & language version managers

✅ **Resolved 2026-08-25** — took the "patch now" option from the recommendation below
(not the mise migration). Changes made:
- `roles/infrastructure/asdf/tasks/main.yml` rewritten to install via `homebrew` on
  macOS (matches the rest of the repo's pattern) with a `get_url`/`unarchive` fallback
  for Debian mirroring `common-cli/noti.yml`'s existing pattern — Debian path is
  unverified (no Linux box to test against right now).
- All six language roles (`python`, `nodejs`, `golang`, `deno`, `terraform`, `gohugo`):
  `asdf plugin-add` → `asdf plugin add`, `asdf global` → `asdf set --home`.
- `bin/check-asdf-installed-for-updates.sh`: `asdf list-all` → `asdf list all`.

Verified live: `bash bin/doi -t asdf` installed asdf 0.20.0 via homebrew; then
confirmed directly that `asdf global` now errors (`invalid command provided: global`)
while `asdf set --home`/`asdf list all`/`asdf plugin add` are the real current
subcommands (per `asdf --help`) — matching what the six edited roles now call.

Left below (including the original "not yet fixed" framing) as the record of what was
found and why.

---

**This is a live outage, not staleness.** asdf underwent a Go rewrite starting at v0.16.0
(Feb 2025); current stable is v0.20.0. Verified against asdf's own upgrade guide
(asdf-vm.com/guide/upgrading-to-v0-16.html). Two independent breaking effects on this
repo:

**A. The asdf install task itself doesn't produce a working binary.**
`roles/infrastructure/asdf/tasks/main.yml:10-14` fetches the latest GitHub release tag
and `git clone`s it into `~/.asdf` with no build step. Since v0.16, asdf is a compiled Go
binary — a bare clone gets you source, not an executable. `asdf` would not exist as a
command after this role runs on a fresh machine.

**B. Every downstream language role uses command syntax asdf removed outright in v0.16:**

| Old (removed, hard error) | New |
| --- | --- |
| `asdf plugin-add <name> <url>` | `asdf plugin add <name> <url>` |
| `asdf global <tool> <version>` | `asdf set --home <tool> <version>` |
| `asdf local <tool> <version>` | `asdf set <tool> <version>` |
| `asdf update` | removed — upgrade via package manager |
| `asdf list-all` | `asdf list all` |

Affected — all six use the dead syntax at both the plugin-add and the global/set step:

| Role | plugin-add line | global/set line |
| --- | --- | --- |
| `roles/infrastructure/python/tasks/main.yml` | 44 | 55 |
| `roles/infrastructure/nodejs/tasks/main.yml` | 39 | 56 |
| `roles/infrastructure/golang/tasks/main.yml` | 21 | 39 |
| `roles/infrastructure/deno/tasks/main.yml` | 44 | 63 |
| `roles/infrastructure/terraform/tasks/main.yml` | 23 | 34 |
| `roles/infrastructure/gohugo/tasks/main.yml` | 18 | 29 |

`bin/check-asdf-installed-for-updates.sh` also uses `asdf list-all "$plugin"`, which needs
to become `asdf list all "$plugin"`. (`asdf list` and `asdf latest`, also used by these
scripts, are unaffected.)

These are the same six files as the `failed_when` bug in [§1.2](#sec-1-2) — fix both in the same pass.

**Not broken:** the vendored oh-my-zsh asdf plugin
(`files/zsh/ohmyzsh/plugins/asdf/asdf.plugin.zsh`) already uses the current
PATH/shims-based shell integration — no old `. asdf.sh` sourcing anywhere. Shell-side is
fine as-is.

### Recommendation: patch now, consider `mise` as a deliberate follow-up

Two real options, not a false binary:

1. ✅ **Chosen 2026-08-25 — Patch the six roles to asdf's new syntax + fix the install
   role to build the Go binary (or install via `homebrew` on macOS like every other role
   in this repo does).** Small, low-risk, unblocks setup today.
1. **Migrate to [mise](https://mise.jdx.dev/)** (formerly `rtx`). WebSearch turned up a
   consistent 2026 consensus recommending mise over asdf specifically for the failure
   mode hit here:
   - Asdf-plugin-compatible — consumes the same plugin URLs this repo already references
     (`asdf-vm/asdf-nodejs`, etc.), so it's not a rewrite from scratch.
   - Single static binary, no build/shim-sourcing fragility — removes exactly the class
     of problem in (A) above.
   - Reportedly ~10x lower per-command overhead than asdf's shims, faster installs.
   - Native `.tool-versions` support (compatible with this repo's existing pinning style).
   - Notable: `files/zsh/ohmyzsh/plugins/mise/` is **already vendored** via the oh-my-zsh
     plugin set but not enabled in `files/zsh/.zshrc`'s `plugins=(...)` list (only `asdf`
     is enabled, line ~67) — oh-my-zsh already ships mise support, currently unused.

Honest tradeoff: mise's edge is speed and DX polish, not correctness — asdf 0.16+ is
still actively released (through 0.20.0), and patching the six roles is roughly a
30-minute fix versus a multi-hour migration-and-retest effort across every language role
on both OS targets. **If the goal is a working machine before the next setup, patch asdf
now and treat mise as a separate, deliberate follow-up** — don't block on the bigger
migration.

---

<a id="sec-4"></a>
## 4. macOS / Homebrew

- ✅ **Resolved 2026-08-25 (#21)** — **`roles/cli/taskwarrior/tasks/main.yml`** installed
  `[task, taskd, tasksh]` via homebrew unconditionally, but the `taskd` formula (the
  Taskwarrior sync server) has been removed from homebrew-core upstream — `brew install
  taskd` now errors `No available formula with the name "taskd". Did you mean task or
  tasksh?`. Caught by CI, not the original audit sweep (the `tests (macos-latest)` job
  actually installs this role for real — the one piece of functional coverage this repo
  has, and it just proved its worth). Fix: dropped `taskd` from the list. Verified live
  (`bash bin/doi -t taskwarrior`): `task` and `tasksh` install cleanly, `failed=0`.
- ✅ **Resolved 2026-08-25** — **`roles/software/authy/tasks/main.yml`** installed the
  Authy desktop app via `homebrew_cask: name: authy`. Twilio discontinued **all** Authy
  desktop apps (Win/Mac/Linux) on 2024-03-19 and force-logged-out desktop users; the cask
  installed a dead shell with no working backend.
  ([ghacks](https://www.ghacks.net/2024/01/08/authy-authenticator-apps-for-desktop-are-being-discontinued-in-august-2024/),
  [Twilio's own changelog](https://www.twilio.com/en-us/changelog/end-of-life--eol--of-twilio-authy-desktop-apps))
  Role and its `dotfiles.yml` entry removed. Bitwarden (already in this repo) has
  built-in TOTP if a desktop 2FA manager is still wanted.
- ✅ **Resolved 2026-08-30 (#24)** — **`roles/cli/common-cli/defaults/main.yml`**
  declared `neofetch` (its author archived the project in 2024; the formula has since
  been pulled from homebrew-core entirely — `brew install neofetch` now errors `No
  available formula with the name "neofetch"`). `tasks/main.yml`'s first install task
  loops over every `default`-keyed package inside an unprotected `block:` with no
  `rescue:`; Ansible loops run every item even after one fails, but the *task* itself
  still reports failed once the loop finishes, and that failure aborted the block right
  there — so the homebrew-only task (`act`, `broot`, `coreutils`, `eza`, `sd`,
  `wifi-password`, `zoxide`) and the `jump.yml`/`noti.yml`/`uv.yml` imports scheduled
  after it in the same block never ran. Same failure shape as #22 (a dead/removed
  Homebrew reference inside an unprotected block killing everything scheduled after it).
  Caught by diffing a fresh MacBook Air 13 setup against a MacBook Pro 16 snapshot
  (`docs/2026-08-23-macbookpro16-installed-apps.txt`) — `brew leaves -r` on the Air was
  missing exactly the tools that live after `neofetch` in `defaults/main.yml`'s list.
  Fix: replaced `neofetch` with **`fastfetch`**, its actively-maintained, drop-in
  successor (Homebrew's own tagline: "Like neofetch, but much faster because written
  mostly in C"). Verified live (`bash bin/doi -t common-cli`, twice): `failed=0`, and
  every previously-missing tool now resolves on `$PATH` (`fastfetch`, `act`, `broot`,
  `eza`, `sd`, `wifi-password`, `zoxide`, `noti`, `uv`; `coreutils` installs
  `g`-prefixed binaries so it has no bare `coreutils` command, confirmed via
  `brew list coreutils` instead).
- ✅ **Resolved 2026-08-30 (#25)** — **`roles/cli/youtube-dl/tasks/main.yml`** installs
  `youtube-dl` via the default package manager. That formula has also been removed from
  homebrew-core (`brew install youtube-dl` errors the same way `neofetch` did) — flagged
  independently in the MacBook Pro 16 snapshot's own `brew doctor` output ("kegs have no
  formulae... neofetch, youtube-dl"). Development on youtube-dl itself has stalled
  upstream; **`yt-dlp`** is the actively-maintained fork (superset of features, same CLI
  shape for most flags). Fix: swapped the installed package to `yt-dlp`; deliberately
  kept the role directory/tag name as `youtube-dl` to avoid churning the tag and the
  docs/history that reference it, with a comment explaining why. Verified live
  (`bash bin/doi -t youtube-dl` — takes ~4.4 min, this role also rebuilds
  `homebrew-ffmpeg/ffmpeg/ffmpeg` from source with `with-fdk-aac`): `failed=0`, `yt-dlp`
  resolves on `$PATH` alongside `atomicparsley` and the rebuilt `ffmpeg`.
- **`roles/infrastructure/macos-infra/tasks/main.yml:17`** — `appcleaner` cask commented
  out since 2024-03-17 citing a SHA1 mismatch (`# TODO: Fix later`). Verified AppCleaner
  is current in homebrew-cask today (v3.6.8); historical SHA1-mismatch reports trace to
  local network/proxy interference, not a broken cask. Worth re-enabling and retesting.
- **`roles/infrastructure/macos-infra/tasks/main.yml:11`** — `homebrew/cask-drivers` tap
  and `logitech-unifying` cask commented out with no note on why or what replaced them
  (Logi Options+ appears to be installed separately) — likely intentional, but
  undocumented; add a comment or remove the dead lines.
- **VirtualBox on Apple Silicon** (`roles/software/virtualbox/tasks/main.yml`) installs
  unconditionally on Darwin with no ARM caveat. ARM64 host support landed in VirtualBox
  7.1 (Sept 2024) and has matured through 7.2.x (current), but Oracle's own docs still
  call it experimental and it lags Parallels/VMware Fusion in stability. Not broken, but
  worth a comment (mirroring the existing "not supported on m1" note already in
  `roles/infrastructure/terraform/tasks/main.yml`) so a fresh M-series setup isn't
  surprised by rough edges.
- **`community.general.homebrew_cask` is confirmed not deprecated** — actively
  maintained. No action needed there beyond the general FQCN-consistency point in
  [§1.7](#sec-1-7).
- **`group_vars/all/mas.yml`** — all 6 App Store IDs (bitwarden, clocker, display_menu,
  kindle, okta_verify, trello) verified still live. No stale IDs.
- **`roles/infrastructure/macos-initial-configuration`** — LaunchAgent-based keyboard
  remapping and `defaults`/dock config are still structurally valid on current macOS.
  One reliability note: since macOS Ventura, background LaunchAgents require explicit
  user approval in System Settings → General → Login Items — a first-time install can
  silently no-op until approved in the GUI. Worth a `debug` message telling the user to
  check Login Items, matching the existing "requires a restart" reminder pattern already
  in the role.
- **Cross-platform cohesion gap** (relevant to "cohesive environment everywhere"):
  `roles/software/{granted,craftnotes,notesnook,box-drive}` all have explicit
  `debug: msg: "TODO: Implement for debian?"` stubs — these four tools are macOS-only in
  practice today, so a Linux machine set up from this repo doesn't get the same toolset.
  Not urgent, but worth tracking if "same environment everywhere" is a hard goal.

---

## 5. Security

Repo confirmed public (`git remote -v` → `github.com/johannesgiorgis/.dotfiles.git`, no
private-fork indicators).

### 5.1 Unauthenticated remote-code-execution installers, no integrity verification
Four places pipe a live remote script straight into an interpreter, trusting whatever the
upstream host serves that day, with no checksum/signature check and no version pin:

- `roles/cli/claude-code/tasks/main.yml:5` — `curl -fsSL https://claude.ai/install.sh | bash`
- `roles/cli/common-cli/tasks/uv.yml:16` — `curl -LsSf https://astral.sh/uv/install.sh | sh`
- `roles/infrastructure/ollama/tasks/main.yml:9` — `curl -fsSL https://ollama.com/install.sh | sh`
- `roles/infrastructure/rust/tasks/main.yml:29-37` — downloads `https://sh.rustup.rs` via
  `get_url` then executes it (same pattern, more visible, still unverified/unpinned)

This is a standard pattern for these specific tools (all four vendors publish exactly
this install method) and may be an accepted risk — but right now it's an *implicit*
accepted risk, not a documented one. Where the vendor publishes a checksum (rustup, uv
both do), pinning it is possible; where not, at minimum note in the role that this is a
deliberate trust-the-vendor decision.

<a id="sec-5-2"></a>
### 5.2 `apt-key add` widens trust more than necessary
`roles/infrastructure/docker/tasks/debian.yml:43-45`:
`shell: curl -sSL {{ docker_apt_gpg_key }} | apt-key add -`. This is the same task
flagged as dead/redundant in [§1.3](#sec-1-3) — it also makes the key trusted
**system-wide for any repo**, not just Docker's, which is broader trust than necessary
and is the deprecated mechanism generally.

✅ **Resolved 2026-08-25** — the `deb822_repository` migration in [§2.1](#sec-2-1) removed
this task entirely; `signed_by:` now scopes the key to just the Docker repo.

### 5.3 `sshd_config` file mode typo
`roles/infrastructure/linux-openssh/tasks/main.yml:26`: `mode: 06444` (unquoted) — almost
certainly meant `"0644"`. setuid/setgid bits are inert on a non-executable file so
there's no live exploit, but it's evidence of an unreviewed mode string, and this repo has
no consistent convention of quoting mode values (`mode: 0700`, `mode: 06444`,
`mode: '0755'`, `mode: "775"` all appear across roles — unquoted leading-zero numbers get
parsed as octal by Ansible's YAML loader, a latent footgun elsewhere too).
**Fix:** `mode: "0644"`, and standardize on always-quoted mode strings repo-wide.

<a id="sec-5-4"></a>
### 5.4 Credential-handling scripts print secrets to stdout
`bin/assume-aws-role.sh` and `bin/aws-get-env.sh` both echo
`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`/`AWS_SESSION_TOKEN` in plaintext to the
terminal for `eval`. Standard pattern for this kind of helper, but it means these values
land in shell history/scrollback/terminal-recording tools with no redaction. Low
actionability — flagging as an inherent design tradeoff, not a bug.

<a id="sec-5-5"></a>
### 5.5 GitHub Actions pinned to mutable refs, not versions

✅ **Resolved 2026-08-25** — `actions/checkout` pinned to `@v7` (both jobs, consistent),
`actions/setup-python` (new, for the ansible-lint job) pinned to `@v7`. Confirmed via
`git ls-remote --tags` that `v7` exists for both before using it.

Update, same day: `ludeeus/action-shellcheck` was pinned to `@2.0.0` — briefly replaced
with a local-script-based `make shellcheck` approach, then **reverted back to the
action** on repo owner's call once actually thought through out loud — see
[§6.7](#sec-6-7) for the reasoning (short version: the action is fast and cheap;
consolidating onto a local script only pays off when CI is slow/heavy or you want
pre-commit-style checks, neither true here). `@2.0.0` pin stands as originally landed.

`.github/workflows/tests.yml`: `actions/checkout@v3` (two majors behind — v4/v5 current),
`actions/checkout@main` (line 41, floating branch — code changes upstream run in your CI
automatically with no version boundary), `ludeeus/action-shellcheck@master` (third-party
action pinned to a mutable branch). **Fix:** pin to a release tag or commit SHA; bump
checkout to current major; be consistent across both jobs in the same file.

<a id="sec-5-6"></a>
### 5.6 No explicit `permissions:` block in the workflow

✅ **Resolved 2026-08-25** — added a top-level `permissions: contents: read` block.

Relies on the org/repo default `GITHUB_TOKEN` scope rather than declaring least-privilege
explicitly. Low risk here (the workflow doesn't touch repo contents/PRs), but cheap to
add: `permissions: contents: read`.

### 5.7 `.gitignore` doesn't cover credential-shaped files
Currently only excludes editor dirs, logs, `.DS_Store`, `.tool-versions`, and zsh-plugin
cruft — nothing for `.env`, `*.pem`, `id_rsa*`, or an AWS `credentials` file. Nothing in
the repo currently writes such files into the tree, so this is latent, not active — cheap
insurance to add given [§5.4](#sec-5-4)'s
script output could tempt a future `> file` redirection.

### Checked, clean
No hardcoded API keys/tokens/passwords found anywhere in `bin/`, `roles/`, `group_vars/`,
`files/`, `docs/`. `become: "{{ should_be_root }}"` usage (~30+ occurrences) is
consistently scoped to tasks that actually need root — no unnecessary escalation found.
No world-writable file modes found.

---

## 6. CI, tooling & maintainability

<a id="sec-6-1"></a>
### 6.1 `bin/doi` bootstrap fails on current Ubuntu/Pop!_OS

⏭️ **Skipped 2026-08-25** — current machine setup is macOS-only, so this wasn't
exercised. Still open; needed before this repo is run again on a fresh Ubuntu/Pop!_OS
box.

`bin/doi:283-312`, `ensure_ansible_is_present()` — the Linux branch matches
`lsb_release -c -s` against `bionic` (18.04, EOL Apr 2023), `focal` (20.04), and `jammy`
(22.04) only. Anything else — including **`noble`, Ubuntu/Pop!_OS 24.04, the current
LTS** — falls through to `fail "ERROR: Unknown linux release code..."; exit 1`.
Bootstrapping ansible itself is step zero of the whole repo; this fails before any role
runs, on the OS version this repo is meant to target right now.

**Fix:** add a `noble` branch, or better, stop keying off codename entirely — a plain
`apt install ansible` has worked uniformly across these releases for years.

### 6.2 `docker/Dockerfile` pinned to `ubuntu:18.04`, EOL, disconnected from real targets
The only containerized test path (`make build`/`make run`/`make all`, referenced in
README's "Testing" section) builds on a base image whose standard support ended over 3
years ago, and doesn't match any of the codenames `bin/doi` handles either. This
container hasn't been exercising anything representative of the real target OS for a
while. **Fix:** update the base image and re-verify the flow works, or mark/remove the
Docker testing path so it stops implying coverage it doesn't provide.

### 6.3 CI covers ~2% of roles

⚠️ **Partially addressed 2026-08-25** — the new `ansible-lint` CI job (see
[§6.4](#sec-6-4)) statically checks all 88 role directories on every push/PR (syntax +
`--profile min` lint), so a structural break like [§1.1](#sec-1-1)'s missing colon or
[§1.2](#sec-1-2)'s `failed_when` bug would now be caught everywhere, not just in the
2 roles below. What's still true: none of that is a *functional* test — nothing actually
installs software from the other 86 roles in CI, so a role that's syntactically valid but
functionally broken (wrong package name, bad URL, wrong module args at runtime) still
only gets caught by running it for real. Expanding functional coverage is a separate,
larger effort (picking roles that are fast/deterministic/non-GUI enough to run in CI).

`.github/workflows/tests.yml` smoke-tests 2 of 88 role directories (`taskwarrior`, `zsh`)
across the macOS/Ubuntu matrix. Every other role — asdf, python, nodejs, terraform, all
of `software/*`, all `macos-*`/`linux-*` infra roles — has zero CI coverage. Regressions
in those are only caught by running them for real on a machine being set up, which is the
worst possible time to discover a break (as this audit's asdf and bin/doi findings
demonstrate directly).

<a id="sec-6-4"></a>
### 6.4 `ansible-lint` is installed but never invoked

✅ **Resolved 2026-08-25** — added a new `ansible-lint` job to
`.github/workflows/tests.yml` (`ubuntu-latest`, `actions/setup-python@v7` +
`pip install ansible ansible-lint`, then `ansible-galaxy collection install -r
requirements.yml` so `community.general` modules resolve, then
`ansible-playbook dotfiles.yml -i hosts --syntax-check` and
`ansible-lint --profile min dotfiles.yml`). Deliberately used the `min` profile, not the
default/production one — this repo trips FQCN, task-naming, and blank-line rules on
nearly every file, and gating CI on the full style profile immediately would demand a
repo-wide style rewrite just to turn linting on. `min` catches real correctness issues
(bad module args, the exact `failed_when`-type-mismatch class of bug, unresolvable
modules) without the noise; tightening the profile is a natural future step once that
style backlog is worked down separately. Also extended the workflow's `push.paths`
filter to include `roles/**`, `dotfiles.yml`, `group_vars/**`, and `requirements.yml` —
previously a direct push to `main` touching a role wouldn't trigger CI at all (only
`pull_request` had no path filter), which would have made the new job dead weight for
how this repo is actually worked on.

Verified before merging: ran the exact same steps in a clean local venv
(`python3 -m venv`, `pip install ansible ansible-lint`,
`ansible-galaxy collection install -r requirements.yml`) — both the syntax-check and
`ansible-lint --profile min dotfiles.yml` passed cleanly (0 failures, 0 warnings, 137
files processed). This also required creating `requirements.yml` (repo root, pins
`community.general: ">=13.3.0,<14.0.0"`) — see [§1.7](#sec-1-7)/#12, partially resolved
by this same change (the collection is now pinned and used by CI; `bin/doi`'s local
bootstrap doesn't consume it yet, and there's still no `ansible.cfg`).

`bin/doi:287` already does `brew install ansible ansible-lint` on macOS bootstrap — it's
already a declared dependency — but there's no `.ansible-lint` config, no CI job, and no
Makefile target that runs it. **This is the single highest-leverage fix available**: an
`ansible-lint` + `ansible-playbook --syntax-check` CI job would have caught the two
highest-severity bugs in this whole audit automatically — the missing `when:` colon in
`dotfiles.yml` ([§1.1](#sec-1-1), malformed role-dict schema)
and the `failed_when` type-mismatch repeated across 6 roles
([§1.2](#sec-1-2), exactly the class of
mistake ansible-lint's condition-type rules catch). Cost: one more CI job, using a tool
already installed.

### 6.5 Documented practices have lapsed
- README's "Updates" section documents a `git tag -a <version>` convention;
  `git tag -l` shows only `v1.0` (2021-05), `v2.0.dev0` (2021-12), `v2.0.dev1` (2022-10) —
  nothing in ~4 years despite continuous commits. Either resume tagging on meaningful
  milestones or drop the documented convention.
- README's MacOS section says `git checkout explore-ansible-2` — that branch still exists
  on the remote (along with `explore-ansible`, `explore-ansible-backup`,
  `explore-ansible-zsh-antigen-role`) but current work is on `main`. A fresh-clone reader
  following the README literally checks out a years-old exploratory branch instead.
- `Makefile`'s `rm-.tf-dir` target references a `services/` directory that doesn't exist
  anywhere in this repo — looks copied from a different (likely work) repo, never adapted
  or removed.
- `roles/cli/common-cli/defaults/main.yml:8-9` installs `act` (used by `make ci`) via
  Homebrew only, no apt/Linux equivalent — `make ci` likely doesn't work out of the box
  on a freshly-bootstrapped Linux box.
- `docs/ansible-readme.md` (the "how I learned ansible" migration journal) teaches a
  generic `package:` + per-OS `when:` pattern that current roles don't actually follow
  (roles use dedicated `homebrew`/`homebrew_cask`/`apt` tasks instead) — still useful as
  rationale (the `should_be_root` pattern it describes is exactly what's live in
  `dotfiles.yml` today), just describes an approach later superseded. No consolidation
  needed elsewhere in `docs/`; `docs/todo.md`'s "Potential Installations" list has likely
  grown stale over the years and is worth a separate prune pass.

<a id="sec-6-6"></a>
### 6.6 `bin/gico` — real shellcheck findings surfaced by the new CI job (#20)

✅ **Resolved 2026-08-25.** With `ludeeus/action-shellcheck` pinned to `@2.0.0` (§5.5),
the shellcheck job actually ran meaningfully for what's likely the first time in a while
(this repo's work has been on a feature branch; the run that surfaced this was
PR-triggered) and failed on real findings in `bin/gico` — the only file with any:
- Line 22: `git clone $new_git_url` / line 26 `git clone $repo` — unquoted, SC2086. Real
  bug: breaks on paths containing spaces or shell glob characters.
- Line 22: `$(echo "$repo" | sed "s/.../.../")` — SC2001 style hit, bash parameter
  expansion is both simpler and avoids a subshell + sed.

Initially suspected the three `.py` files in `bin/` (`cdk-qualifier.py`,
`check-asdf-updates.py`, `weekly-template.py`) — a naive `shellcheck <file>` over
everything in `bin/` errors on all three (SC1071, "not a shell script"). That was a false
lead: the action's own file-discovery logic (`action.yaml`) only matches known shell
extensions, or extensionless+executable files with an `sh`-family shebang — `.py` files
never match either branch, so they were never actually in scope. Confirmed by
reproducing the action's exact `find` logic locally against `bin/` before and after the
fix.

**Fix:** quoted both `git clone` invocations, replaced the `sed` pipeline with
`"${repo//github.com/$PERSONAL_GITHUB_URL}"`. Verified by reproducing the action's real
scan set locally and running `shellcheck` with its actual default severity (`style`,
which shows everything) against exactly those files — clean before only `gico`, clean
across the board after.

<a id="sec-6-7"></a>
### 6.7 Shellcheck consolidation tried, then reverted — and applied to `ansible-lint` instead, where it actually fits

⏭️ **Reverted 2026-08-25, same day it landed.** Briefly consolidated the shellcheck job
onto a local script (`bin/shellcheck-local.sh` + `make shellcheck`, replacing
`ludeeus/action-shellcheck` entirely) for the reasons in the original version of this
section: single source of truth, nothing to keep in sync between CI config and a local
script. Caught one real thing on the way — a BSD-vs-GNU `find -perm` portability bug
(`+111` vs `/111`, neither works on both) — before it reached CI, by actually running the
script rather than assuming it worked.

**Reverted after talking it through.** Repo owner's reasoning, and it holds up: the
shellcheck job is cheap and fast (~1s, `shellcheck` ships preinstalled on
`ubuntu-latest`) — push-and-check is already as fast as running it locally, so there's no
real feedback-loop benefit to a local target here, only the cost of owning file-discovery
logic ourselves (and the portability bug above is exactly the kind of cost that
predicts). The general rule that came out of this: **consolidating CI onto a local
command pays off when CI is slow/heavy, or when you want pre-commit-style checks before
a commit even happens — not by default just because duplication is possible.**
`bin/shellcheck-local.sh` removed; `.github/workflows/tests.yml`'s `shellcheck` job is
back to `ludeeus/action-shellcheck@2.0.0` exactly as landed in [§5.5](#sec-5-5).

**Applied where it actually fits: `ansible-lint`.** Unlike shellcheck, that CI
job pip-installs `ansible`+`ansible-lint` from scratch every run — genuinely not cheap —
and the same tools are already sitting installed locally (via `bin/doi`'s own bootstrap),
so a local target costs nothing to add and saves a real round-trip. Added `make lint`
(`ansible-galaxy collection install -r requirements.yml` +
`ansible-playbook --syntax-check` + `ansible-lint --profile min`) and changed the CI
job's last three steps to just `make lint`. Verified locally: `make lint` passes clean
(0 failures, 137 files). YAML validated.

---

<a id="sec-7"></a>
## 7. Zsh / shell configuration

Neither finding in this section came from the original 6-agent audit sweep — both surfaced
from a real bug report (repo owner hit actual crashes on this machine) mid-session, then
got investigated and fixed the same way as everything else in this doc.

<a id="sec-7-1"></a>
### 7.1 `zsh` role: dead `homebrew_tap` task, unprotected `block`, cascaded into a broken live shell (#22)

✅ **Resolved 2026-08-25.** Reported symptom: every new terminal produced
`plugin 'fd' not found`, `plugin 'ripgrep' not found`,
`process substitution failed: no such file or directory` (×2), a real zsh crash
(`malloc: *** error for object ... pointer being freed was not allocated`), and
`rust.plugin.zsh:27: no such file or directory: .../zsh/cache/completions/_cargo`.

**Root cause, confirmed from an actual run log the repo owner captured:**
`roles/infrastructure/zsh/tasks/main.yml` had a task —
`ZSH - Tap homebrew/command-not-found (homebrew)` — inside the same unprotected `block:`
as the theme/plugin git clones, with no `rescue:`. That tap is permanently gone:
```
Error: homebrew/command-not-found was deprecated. This tap is now empty and all its
contents were either deleted or migrated.
```
Because the task lived inside a `block:` with no `rescue:`, Ansible aborted the entire
play at that point — confirmed via the actual recap: `failed=1`, and every task listed
after it in the file never ran. The very next task in the file was
`ZSH - Create folders [~/.zfunc|~/zsh/(cache|completions)]` — the one thing that creates
`~/zsh/cache/completions`, which `.zshrc` sets `ZSH_CACHE_DIR` to and the `rust` oh-my-zsh
plugin writes completion files into on every shell startup. That directory never got
created. Every symptom above is a direct or indirect consequence of writes into a
directory that doesn't exist — including the malloc crash, a known zsh failure mode when
`=(...)` process substitution (used by `rust.plugin.zsh`) can't materialize its backing
file combined with a backgrounded job (`&|`).

The failure happened once, during initial machine setup, and was visible in the ansible
output at the time — but nothing about a `homebrew_tap` failure message suggests "your
shell will crash on every future startup," and the actual symptom didn't show up until a
completely disconnected later moment (opening a new terminal). That gap between cause and
visible effect is why this took investigation rather than being obvious from the error
text alone.

**Also confirmed unnecessary, not just broken:** Homebrew moved `command-not-found`
handling into `brew` core itself
([docs](https://github.com/Homebrew/brew/blob/main/docs/Command-Not-Found.md)) — the
oh-my-zsh `command-not-found` plugin already checks that built-in path first
(`Library/Homebrew/command-not-found/handler.sh`), confirmed present on this machine.
The tap was superseded, not just deprecated; removing the task loses nothing.

**Fix, three parts:**
1. Deleted the `homebrew_tap` task entirely.
1. Moved `Create folders [~/.zfunc|~/zsh/(cache|completions)]` to run immediately after
   the `~/zsh` symlink step — before the fragile theme/plugin/tap block — so a future
   failure anywhere in that block can never again cascade into a missing directory the
   shell actually needs. General principle: "must have" (shell can't start cleanly
   without it) should never be sequenced after "nice to have" (cosmetics) with no
   isolation between them.
1. Defensive fix in `.zshrc` itself: `mkdir -p "$ZSH_CACHE_DIR/completions"` right after
   `ZSH_CACHE_DIR` is set — makes the shell self-healing regardless of whether ansible
   setup ever completes cleanly, closing off this whole class of failure independent of
   the role fix.

**Verified live, not just by reading the diff:** `ansible-playbook --syntax-check` and
`--list-tasks --tags zsh` confirmed the new order and that the dead task no longer
appears. Repo owner ran `bash bin/doi -t zsh -a` for real (needed interactively for the
sudo prompt on a separate task — I can't supply that through this interface) and
confirmed the crash/process-substitution/malloc errors are gone; only the
already-separately-tracked `fd`/`ripgrep` warnings remained (see [§7.2](#sec-7-2)).

<a id="sec-7-2"></a>
### 7.2 Dead/never-existed oh-my-zsh plugin entries: `fd`, `ripgrep`, `timewarrior` (#23)

✅ **Resolved 2026-08-25** (repo owner commented out `fd`/`ripgrep`; `timewarrior` was
already commented out). `files/zsh/.zshrc`'s `plugins=()` array included `fd` and
`ripgrep`, both producing `[zsh] plugin '<name>' not found` at every shell startup —
this repo's `.zshrc` uses a hand-rolled plugin loader (not upstream oh-my-zsh's) that
checks `$ZDOTDIR/plugins/<name>/` and `$ZDOTDIR/ohmyzsh/plugins/<name>/` for a
`<name>.plugin.zsh` file and warns if neither exists.

Traced the actual history in the vendored oh-my-zsh git checkout (a real, full clone —
`git log` has all 7864 commits despite the sparse checkout):

| Plugin | Added | Removed | Commit | Reason |
| --- | --- | --- | --- | --- |
| `fd` | 2018-09-27 | 2024-07-23 | `c7c11e11` | "the `fd` plugin has been removed, as it only shipped its completion, which is now already included in all the usual package managers" (oh-my-zsh's own changelog, flagged as a BREAKING CHANGE) |
| `ripgrep` | 2018-09-27 | 2024-07-23 | `09a3eb69` | same reasoning, same PR (#12576) |
| `timewarrior` | — | — | — | **never existed** — no add or delete history at all, unlike `fd`/`ripgrep` which were real and got deliberately retired |

Confirmed both tools' completions already work independent of any oh-my-zsh plugin:
Homebrew installs `_fd`/`_rg` directly into `/opt/homebrew/share/zsh/site-functions`,
already on `$FPATH`. Removing the dead entries loses no functionality.

**Full plugin-list audit while investigating (not just the two reported):** checked every
other active entry in `plugins=()` against the vendored oh-my-zsh checkout for existence
and any deprecation notice. All confirmed current and valid — nothing else in the active
list needs attention. Two commented-out entries worth noting for whenever they're
revisited: `fzf` would be redundant even if re-enabled (`.zshrc` already initializes fzf
directly via `eval "$(fzf --zsh)"` elsewhere); `taskwarrior` is a valid, currently-unused
plugin — notable since this repo's `taskwarrior` role (§4/#21) does install the tool
itself, just not its shell integration.

<a id="sec-8"></a>
## 8. Software inventory gaps (work MacBook Pro 16)

Not correctness bugs — this repo's stated goal is capturing the journey of software
actually used, not 100% reproducibility, so none of #26–#29 block anything. Found by
diffing this machine's `brew leaves -r`, `brew list --cask`, and `mas list` (captured in
`docs/2026-09-01-work-macbookpro16-installed-apps.txt`) against every role and
`group_vars/all/mas.yml`.

<a id="sec-8-1"></a>
### 8.1 Jira/Atlassian CLI (`acli`) — #26
`acli` (Atlassian's official CLI, covers Jira) is installed via
`brew install atlassian/acli/acli` (1.3.29-stable on this machine) but has no role, and
no other Jira/Atlassian CLI tool (e.g. `ankitpokhrel/jira-cli`) appears anywhere in the
repo either. Was installed by hand, never captured back.

### 8.2 Work-machine CLI tools & Mac App Store apps installed but uncaptured — #27
**CLI (`brew leaves -r`, no role installs these):** `ansible-lint`, `yamllint` — ironic
given CLAUDE.md's own lint conventions reference them, but nothing installs them, only
documents using them once present; `bfg` (BFG Repo-Cleaner); `git-secrets`; `pnpm`;
`postgresql@14`; `subversion`; `mypy`. Lower-signal, likely transitive/manual GUI-lib
installs rather than tools actually reached for: `gdk-pixbuf`, `libffi`, `pango`,
`pkgconf`.

**Mac App Store (`mas list`, not in `group_vars/all/mas.yml`):** Adblock Plus, Be
Focused, GIPHY Capture, Lightshot Screenshot, Microsoft To Do, Monosnap, Okta Extension
App.

### 8.3 Homebrew casks installed but uncaptured — #28
`brew list --cask` vs `roles/software/*` + `roles/work-macos-software`: `iterm2` is the
notable one — it's the actual terminal in daily use and has zero role anywhere. Also
uncaptured: `arc`, `cursor`, `zed`, `alt-tab`, `rectangle`, `aerial`, `obsidian`,
`superlist`, `omnidisksweeper`, `ungoogled-chromium`, `chatgpt`, `claude`,
`claude-code-history-viewer`, `logi-options-plus`, `aws-vault-binary`.
`roles/work-macos-software` covers `microsoft-word`/`excel`/`powerpoint` but not the
also-installed `microsoft-onenote`, `microsoft-outlook`, `microsoft-teams`,
`microsoft-auto-update`. Separately, `diffmerge` is installed but flagged deprecated by
`brew doctor` and has no role — likely fine as a legacy leftover to note rather than a
role to add.

### 8.4 `flux` role cask name has drifted from upstream — #29
`roles/software/flux/tasks/main.yml:6` installs cask `flux`; this machine's actual
installed cask is `flux-app` (upstream rename). Same shape as #21/#22/#24/#25 — a role
referencing a Homebrew name that's since moved — just not yet hit at install time since
`flux` may still resolve today. Worth confirming which cask name is currently correct
before the old one breaks like the others did.
