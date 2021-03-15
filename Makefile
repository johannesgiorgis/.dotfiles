
IMAGE_NAME:=dotfilestest

build-no-cache:
	docker build --rm --no-cache -t $(IMAGE_NAME):1.0 .

build:
	docker build --rm -t $(IMAGE_NAME):1.0 .

run:
	docker run -it --name $(IMAGE_NAME) -v ~/.dotfiles:/home/tester/.dotfiles --rm $(IMAGE_NAME):1.0 zsh

all: build run

all-dev: build-no-cache run

ansible-info:
	ansible -m setup localhost

ansible-inventory:
	ansible-inventory -i ansible/hosts --host local

code-extensions-info:
	code --list-extensions

brew-installs:
	rg -N  'brew_install|brew_cask_install|brew install|cask install' macos/install-software-via-brew.sh | grep -o 'install .\+' | cut -d' ' -f2- | tr ' ' '\n' | sort -u

check-asdf-updates:
	bash asdf/check-asdf-installed-for-updates.sh

list-ansible-tags:
	bash bin/dot-bootstrap

zsh-sections:
	rg '<<<|>>>' ~/.zshrc
