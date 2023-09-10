# Learnings - Shellcheck

## Unused variables

Shellcheck found unused variables which is great from a debugging perspective 🎉

## Bash Parameter Expansion for simplified replacement

Shellcheck pointed out an opportunity to simplify a string replacement and after some debugging, I got it working exactly as I wanted.

Below is the shellcheck output that led to this learning:

```sh
λ  shellcheck check-asdf-installed-for-updates.sh

In check-asdf-installed-for-updates.sh line 52:
            subversion_root=$(echo "$installed_version" | sed 's/[0-9]*$//')
                              ^-- SC2001 (style): See if you can use ${variable//search/replace} instead.

For more information:
  https://www.shellcheck.net/wiki/SC2001 -- See if you can use ${variable//se...
```

Before we jump to what this line does, we should understand what this script is doing. I use the `asdf` tool to manage the various versions of my development tools - languages, frameworks, etc. It works via plugin system. You install a plugin, then you install a specific version of that plugin (e.g. install nodejs, then install nodejs `18.17.0`). These plugins and versions are codified via my existing ansible roles. When dealing with multiple languages/tools, it is hard to track when you need to update - this applies to major as well as minor versions.

Which leads us to this troublesome line. This line is parsing a plugin version to check for any updated minor versions. Building on our nodejs example, we would want to see if `18.17.0` is indeed the latest minor version (spoilers - it's not - `18.17.1` is available). This line does exactly that. It changes `18.17.0` -> `18.17` which will be used to check for the latest `18.17.X` version.

Now that we understand the context, shellcheck was pointing out this code could be simplified by using bash shell parameter expansions. The tricky part was figuring out how to get it to handle the last match, not the first nor all matches.

Debugging in the terminal:

```sh
λ  i="3.9.9"
# current working code getting us what we want
λ  echo $i | sed 's/[0-9]*$//'
3.9.
# changing to bash parameter expansion with AS IS
λ  echo ${i/[0-9]*$//}
3.9.9
# This changes first occurence
λ  echo ${i/[0-9]//}
/.9.9
# $ which is used to anchor to ending doesn't work
λ  echo ${i/[0-9]$//}
3.9.9

# // is used to replace all matches
λ  echo ${i//[0-9]/X}
X.X.X

# Googling around led to looking at bash shell parameter expansion docs
λ  echo ${i//%[0-9]/X}
3.9.X

# Correct Ouput 🎉
λ  echo ${i//%[0-9]/}
3.9. 
```

From docs:

```sh
# If pattern is preceded by ‘%’ (the fourth form above), it must match at the end of the expanded value of parameter.
${parameter/#pattern/string}
```

## References

- [Shellcheck Wiki - SC2001](https://www.shellcheck.net/wiki/SC2001)
- [StackOverfow Question/Answer](https://stackoverflow.com/a/13210909)
- [Bash Shell Parameter Expansion](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion)
