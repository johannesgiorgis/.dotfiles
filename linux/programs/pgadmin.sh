#!/bin/bash

# Install PGAdmin

sudo apt-get install curl ca-certificates --yes
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update --yes
sudo apt-get install postgresql-11 pgadmin4 --yes