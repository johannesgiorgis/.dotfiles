FROM ubuntu:18.04
LABEL maintainer="johannesgiorgis@users.noreply.github.com" 

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
    bc \
    locales \
    sudo \
    vim-nox \
    less \
    # # libbz2-dev \
    # # libreadline-dev \
    # # libssl-dev \
    # # libsqlite3-dev \
    # snapd \
    && apt-get upgrade -y \
    && apt-get clean

RUN locale-gen en_US.UTF-8

RUN useradd -s /bin/zsh tester
ADD . /home/tester/.dotfiles
RUN chown -R tester:tester /home/tester && \
    echo 'tester ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tester && \
    chmod 0440 /etc/sudoers.d/tester
USER tester

ENV HOME /home/tester
ENV TMUX y
ENV GIT_AUTHOR_NAME Johannes Giorgis
ENV GIT_AUTHOR_EMAIL johannesgiorgis@users.noreply.github.com

WORKDIR /home/tester/.dotfiles
# RUN git submodule update --init
# git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.8
# RUN bash ./scripts/bootstrap.sh # Doesn't work with git clone operatinos to get Oh My ZSH! plugins