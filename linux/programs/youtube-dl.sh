#!/usr/bin/env bash

# Install youtube-dl
# Download videos from YouTube (and more sites)
# http://ytdl-org.github.io/youtube-dl/index.html
# http://ytdl-org.github.io/youtube-dl/supportedsites.html

echo "Installing latest version of youtube-dl..."

# download latest
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl

# make it executable
sudo chmod a+rx /usr/local/bin/youtube-dl 

echo "Completed installing version of youtube-dl"