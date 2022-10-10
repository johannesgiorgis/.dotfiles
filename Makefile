.PHONY: help

IMAGE_NAME:=dotfilestest

help: ## Show this help
	@echo ""
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

rm-.tf-dir:		## find and remove .terraform directories across all services
	find services -type d -name '.terraform' -exec rm -rf {} \;

build-no-cache:		## build docker image with no cache
	docker build --rm --no-cache -t $(IMAGE_NAME):1.0 .

build:		## build docker image
	docker build --rm -t $(IMAGE_NAME):1.0 .

run:		## run docker image
	docker run -it --name $(IMAGE_NAME) -v ~/.dotfiles:/home/tester/.dotfiles --rm $(IMAGE_NAME):1.0 zsh

all: build run	## build and run docker image

all-dev: build-no-cache run		## build docker image with no cache + run it

ansible-info:		## get ansible info about current device in json
	ansible -m setup localhost

ansible-inventory:		## get ansible inventory list in json
	ansible-inventory -i ansible/hosts --host local

code-extensions-info:	## get list of code extensions
	code --list-extensions

brew-installs:		## get brew installs from script
	rg -N  'brew_install|brew_cask_install|brew install|cask install' macos/install-software-via-brew.sh | grep -o 'install .\+' | cut -d' ' -f2- | tr ' ' '\n' | sort -u

check-asdf-updates:		## run script to check updates for asdf installed tools
	bash asdf/check-asdf-installed-for-updates.sh

list-ansible-tags:		## list ansible tags
	bash bin/doi

zsh-sections:		## display zshrc sections
	rg '<<<|>>>' ~/.zshrc
