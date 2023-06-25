#!/usr/bin/env bash

# Set Up Nvidia Container Toolkit with Docker
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#docker

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker