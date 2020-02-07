# Dotfiles

Various settings for the tools I use.

# Testing

Run the following:

```bash
# build docker image and run docker container 
$ make docker-all

# once in the docker container, run
$ bash scripts/bootstrap.sh | tee setup_log.log
```

# Reference

- https://michael.mior.ca/blog/automated-testing-of-dotfiles/
- https://www.freecodecamp.org/news/how-to-set-up-a-fresh-ubuntu-desktop-using-only-dotfiles-and-bash-scripts/
- https://github.com/holman/dotfiles
- https://github.com/victoriadrake/dotfiles
- https://scriptingosx.com/2019/07/moving-to-zsh-06-customizing-the-zsh-prompt/