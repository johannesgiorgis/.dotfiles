FROM ubuntu:18.04
LABEL maintainer="johnny.awg+github@gmail.com" 
# <johnny.awg+github@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    git \
    # man \
    # bison \
    # flex \
    # ed \
    # libbz2-dev \
    # libreadline-dev \
    # libssl-dev \
    # libsqlite3-dev \
    # tmux \
    software-properties-common \
    vim-nox \
    # zsh \
    snapd \
    sudo \
    locales \
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
# ENV GIT_AUTHOR_NAME Johannes Giorgis
# ENV GIT_AUTHOR_EMAIL Johnny.awg+github@gmail.com

WORKDIR /home/tester/.dotfiles
RUN git submodule update --init
# RUN bash ./scripts/bootstrap.sh # Doesn't work with git clone operatinos to get Oh My ZSH! plugins