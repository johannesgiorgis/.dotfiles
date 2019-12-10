#!/bin/bash

# Install Miniconda

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/Downloads/miniconda.sh
chmod +x ~/Downloads/miniconda.sh
bash ~/Downloads/miniconda.sh -b -p ~/miniconda
~/miniconda/condabin/conda init
source ~/.bashrc
conda config --set auto_activate_base false