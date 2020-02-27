# Homebrew Installation

This directory deals with installing [Homebrew] and the packages that are installed via Homebrew and Homebrew Cask.

## Regular Brew

Below are the packages installed via regular `brew install`:

```sh
- black
- cask
- entr
- flake8
- htop
- jq
- pipenv
- postgresql
- pyenv
- speedtest-cli
- tldr
- tree
- watch
- wget
- wifi-password
- youtube-dl
```

Additional system dependencies needed for Python compilation by pyenv (optional, but recommended) [pyenv Wiki]

```sh
- openssl
- readline
- sqlite3
- xz
- zlib
```

## Brew Cask Installations

Below are the packages installed via `brew cask install`:

```sh
- dropbox
- firefox
- google-chrome
- iterm2        # Terminal :)
- joplin        # Note taker
- lepton        # Gist Interface
- meld
- postman       # API development
- rectangle     # Window Management
- simplenote    # Note taker
- sublime-merge # Git Client
- sublime-text  # Local Note Taker
- tunnelblick   # VPN
```

## Brew Custom

Below are the packages installed via `brew tap <package> && <brew|brew cask> install`:

```sh
- displayplacer
- font-fira-code
```

[Homebrew]: https://brew.sh/
[pyenv Wiki]: https://github.com/pyenv/pyenv/wiki