# Learnings - Dynamic Github Releases

I had several packages that were installed directly from their respective Github repo pages. These included

- [delta](https://github.com/dandavison/delta)
- [exa](https://github.com/ogham/exa)
- [simplenote](https://github.com/Automattic/simplenote-electron)

My original implementation included having a `github.yml` file under `group_vars/all` directory to globally define each package's desired version. This way, the package version was under version control and I could have consistency across my various devices regarding the package versions.

```yml
# github - software installed directly from software

# CLI

delta_project: dandavison/delta
delta_version: 0.12.1

exa_project: ogham/exa
exa_version: 0.10.1

jump_project: gsamokovarov/jump
jump_version: 0.41.0

noti_project: variadico/noti
noti_version: 3.5.0

# Infrastructure

dockercompose_project: docker/compose
dockercompose_version: 2.3.3

# Software

rambox_project: ramboxapp/community-edition
rambox_version: 0.7.9

simplenote_project: Automattic/simplenote-electron
simplenote_version: 2.21.0
```

Couple issues cropped up using this approach:

- Package versions were hardcoded so require manual changes - first check for a new version, then update the `github.yml` file and commit it.
- I would most often be running an older version of package and not taking advantage of new package capabilities/bug fixes.

My initial fixes involve creating a script (of course!) to dynamically search for all packages' latest versions - [script](../bin/check-github-software-for-updates.sh).

This script only partially solved the first problem by checking for every package at once. However, it still required me to manually run this script to check. It merely aggregated all the package version checks to happen at once, instead of individually.

So how did I solve this minor annoyance? Well, curl to the rescue! And Github APis of course :)

Taking `asdf` repo as an example, we can get the current latest release version:

```sh
curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq -r '.tag_name'
v0.12.
```

No need to hardcode a repo's release versions OR have to manually check for updates!

Now, we can get the last release version for any github repo and install it.

Translating the above bash snippet to something usable within an ansible role:

```yml
- name: ASDF - Getting latest version from Github API
  shell: >
    curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest
    | jq -r '.tag_name'
  args:
    warn: false
  register: output

- name: ASDF - Clone asdf repository {{ output.stdout }}
  git:
    repo: https://github.com/asdf-vm/asdf.git
    dest: "~/.asdf"
    version: "{{ output.stdout }}"
```

We first get the latest release version (Some packages use `tag_name` while others use `name`) and save it to a variable called `output`. In the next task, we specify the desired package version via `output.stdout`.
