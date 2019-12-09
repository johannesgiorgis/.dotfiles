#!/bin/bash

#################################################
# Setup Ubuntu Laptop
#
# Version History
# ---------------
#
# 2019-08-06: v0.1
#
#################################################

LINE_BREAK="===================================================================================="
function print_stamp() { echo -e "\n$(date +'%F %T') $@"; }


echo "$LINE_BREAK"
print_stamp "$0 Started"

echo "Listing installed snaps:"
snap list

declare -a snap_software_list=(
	"slack --classic"
	"code --classic"
	"sublime-text --classic"
	"firefox"
	"vlc"
	"simplenote"
	"spotify"
	"whatsdesk"
)

echo ''
echo "Installing Snap Software..."

# Read the array values with space
for val in "${snap_software_list[@]}"; do
  print_stamp "Installing '$val': snap install $val"
  sudo snap install $val
  echo "Completed installing $val!"
done

echo ''
echo "Listing installed snaps after installation:"
snap list

# Install pip
print_stamp "Installing pip..."
sudo apt update --yes
sudo apt install python3-pip --yes
which pip3
print_stamp "Completed installing pip!"


# Install aws cli
print_stamp "Installing aws..."
sudo apt install awscli --yes
which aws
aws --version
print_stamp "Completed installing aws!"


print_stamp "Installing F.Lux..."
sudo add-apt-repository ppa:nathan-renniewaldock/flux --yes
sudo apt-get update --yes
sudo apt-get install fluxgui --yes
print_stamp "Completed installing F.Lux!"


print_stamp "Installing PGAdmin 4..."
sudo apt-get install curl ca-certificates --yes
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update --yes
sudo apt-get install postgresql-11 pgadmin4 --yes
print_stamp "Completed installing PGAdmin 4!"

print_stamp "Installing xclip..."
sudo apt install xclip --yes
print_stamp "Completed installing xclip!"

print_stamp "Installing NodeJS and NPM..."
sudo apt-get install curl python-software-properties --yes
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install nodejs --yes
node -v
npm -v
print_stamp "Completed installing NodeJS and NPM!"

print_stamp "Installing Serverless Framework..."
yes | sudo npm install -g serverless
print_stamp "Completed installing Serverless Framework!"

print_stamp "Installing Miniconda..."
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/Downloads/miniconda.sh
chmod +x ~/Downloads/miniconda.sh
bash ~/Downloads/miniconda.sh -b -p ~/miniconda
~/miniconda/condabin/conda init
source ~/.bashrc
conda config --set auto_activate_base false
print_stamp "Completed installing Miniconda!"

print_stamp "$0 Completed"
echo "$LINE_BREAK"
