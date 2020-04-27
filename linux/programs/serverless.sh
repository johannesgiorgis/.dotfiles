#!/bin/bash

# Install Serverless Framework

print_stamp "Installing Serverless Framework..."
yes | sudo npm install -g serverless
print_stamp "Completed installing Serverless Framework!"