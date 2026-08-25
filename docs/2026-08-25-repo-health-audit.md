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
- *(no marker / "Open")* — still open

---

## Status

**At a glance:** 5 resolved, 1 partial, 1 skipped, 12 open — of the 12 open, 3 are gated
on having a Linux/Pop!_OS box (`#4`, `#5`, and the PPA remainder of `#8`); the other 9 are
actionable right now regardless of which machine you're on.

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
| 9 | `state: latest`, 12 locations | High | Ansible | Low | either | Open |
| 10 | Unpinned remote-installer scripts, 4 roles | Medium | Security | Low (document) | either | Open |
| 11 | `apt-key add` over-broad trust (docker) | Medium | Security | Resolved by #8 | — | ✅ Resolved 2026-08-25 |
| 12 | No collections `requirements.yml`/`ansible.cfg` | High | Ansible/reproducibility | Low | either | Open |
| 13 | CI covers 2/88 roles; ansible-lint installed but unused | High | CI | Low | either | Open |
| 14 | `docker/Dockerfile` pinned to EOL `ubuntu:18.04` | Medium | CI | Low | either | Open |
| 15 | GitHub Actions on mutable refs (`@main`/`@master`/old `@v3`) | Low-Medium | Security/CI | Low | either | Open |
| 16 | ~60 shell/command tasks missing idempotency guards | Medium | Ansible | Medium | either | Open |
| 17 | `sshd_config` mode typo (`06444`) | Low | Security | Trivial | either | Open |
| 18 | Stale docs/README references (branch, tagging, dead Makefile target) | Low | Maintainability | Low | either | Open |
| 19 | Cross-platform stubs (granted/craftnotes/notesnook/box-drive Linux TODO) | Low | Cohesion | Medium | Linux + decision | Open |

Detailed writeup for every row lives in the numbered sections below (§1–§6) — jump to §1
"Ansible correctness & idempotency" for the Ansible-domain rows, §2 "Deprecations" for
rows 4/5/8, §4 "macOS/Homebrew" for row 6, §5 "Security" for rows 10/11/15/17, and §6
"CI, tooling & maintainability" for rows 2/13/14/18.

## Next steps (suggested order)

1. **Anything still blocking a real setup run**: #1 and #3 are done; #2 remains skipped
   (needs Linux).
1. **Cheap, high-leverage guardrail**: wire up `ansible-lint` + `--syntax-check` in CI
   (#13) — the bug classes behind #3 and #7 get caught automatically going forward.
1. **Finish the mechanical migration**: `apt_key`/`apt_repository` → `deb822_repository`
   for the 4 remaining PPA-based files (#8 remainder) — needs real per-PPA key lookups,
   ideally verified on Linux.
1. **Cleanup pass**: `state: latest` → `present` (#9), `gnome-shell-extension-tool` fix
   (#5, needs Linux).
1. **Decide, don't just patch**: Pop!_OS/COSMIC (#4) and asdf-vs-mise are real
   architectural questions, not line fixes — see Notes below.

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
  change log to the end. No findings content changed, only reorganized.

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

### 1.4 `state: latest` breaks idempotent convergence — 12 locations
All on `apt:` tasks (no `homebrew`/`pip`/`npm` instances found):

`roles/cli/vim/tasks/main.yml:17`, `roles/cli/common-cli/tasks/main.yml:11,20,38`,
`roles/cli/youtube-dl/tasks/main.yml:12,30,35`, `roles/cli/taskwarrior/tasks/main.yml:12`,
`roles/software/google-chrome/tasks/main.yml:12`,
`roles/software/sqlite-browser/tasks/main.yml:12`,
`roles/software/virtualbox/tasks/main.yml:12`, `roles/software/meld/tasks/main.yml:12`,
`roles/infrastructure/linux-openssh/tasks/main.yml:11`.

Every rerun can silently upgrade these packages — the opposite of converging to a fixed,
reproducible state. **Fix:** `state: present` unless you deliberately want
always-latest for a specific package.

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

- ✅ **Resolved 2026-08-25** — **`roles/software/authy/tasks/main.yml`** installed the
  Authy desktop app via `homebrew_cask: name: authy`. Twilio discontinued **all** Authy
  desktop apps (Win/Mac/Linux) on 2024-03-19 and force-logged-out desktop users; the cask
  installed a dead shell with no working backend.
  ([ghacks](https://www.ghacks.net/2024/01/08/authy-authenticator-apps-for-desktop-are-being-discontinued-in-august-2024/),
  [Twilio's own changelog](https://www.twilio.com/en-us/changelog/end-of-life--eol--of-twilio-authy-desktop-apps))
  Role and its `dotfiles.yml` entry removed. Bitwarden (already in this repo) has
  built-in TOTP if a desktop 2FA manager is still wanted.
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

### 5.5 GitHub Actions pinned to mutable refs, not versions
`.github/workflows/tests.yml`: `actions/checkout@v3` (two majors behind — v4/v5 current),
`actions/checkout@main` (line 41, floating branch — code changes upstream run in your CI
automatically with no version boundary), `ludeeus/action-shellcheck@master` (third-party
action pinned to a mutable branch). **Fix:** pin to a release tag or commit SHA; bump
checkout to current major; be consistent across both jobs in the same file.

### 5.6 No explicit `permissions:` block in the workflow
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
`.github/workflows/tests.yml` smoke-tests 2 of 88 role directories (`taskwarrior`, `zsh`)
across the macOS/Ubuntu matrix. Every other role — asdf, python, nodejs, terraform, all
of `software/*`, all `macos-*`/`linux-*` infra roles — has zero CI coverage. Regressions
in those are only caught by running them for real on a machine being set up, which is the
worst possible time to discover a break (as this audit's asdf and bin/doi findings
demonstrate directly).

### 6.4 `ansible-lint` is installed but never invoked
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
