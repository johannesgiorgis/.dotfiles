# Github Actions Learnings

The biggest learning/change was the renaming of my repo to `.dotfiles`.

Why? Because I cloned my `dotfiles` repo to a local directory called `.dotfiles` and all scripts were set up to run under the `.dotfiles/` directory. This caused issues as Github Action runners checked out the `dotfiles` repo and that's where the scripts were called from.

Googling around led me to this [issue](https://github.com/actions/checkout/issues/197#) (open as of Sep 2023) and this [issue comment](https://github.com/actions/checkout/issues/197#issuecomment-829560171) where someone successfully renamed their repo by copying it over.

After some trial and error, the easiest solution was simply to rename my repo to from `dotfiles` to `.dotfiles`. This would make it consistent everywhere else and simplify my adoption of Github Actions. Github Action runners would check out the same directory and scripts would run with no issues 🎉 A simple fix to a silly solution.

Second learning was something I came across was from the below article on using Github Actions for continuous integration of MacOS based dotfiles. Specifically, the use of environment variables and determining where you were running.

- [CI your MacOS dotfiles with GitHub Actions!](https://mattorb.com/ci-your-dotfiles-with-github-actions/)
- [dotfiles repo](https://github.com/mattorb/dotfiles/tree/master)
