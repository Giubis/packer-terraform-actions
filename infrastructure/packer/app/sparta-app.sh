#!/bin/bash

# Stops the script if a command fails
set -e

# Update and upgrade packages
sudo apt update -y
sudo apt upgrade -y

# Install dependencies
sudo apt install git nginx sed curl -y

# Amend line 51 to use nginx as a reverse proxy
sudo sed -i '51c\proxy_pass http://127.0.0.1:3000;' /etc/nginx/sites-available/default
sudo systemctl restart nginx
sudo systemctl enable nginx

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y

# Switch to the correct user
cd /home/ubuntu

# Remove repository if already existing
sudo rm -rf nodejs20-se-test-app-2025

# Clone repository
git clone https://github.com/Giubis/nodejs20-se-test-app-2025.git

# Install Node dependencies
cd nodejs20-se-test-app-2025/app
npm install

# Install PM2 globally
sudo npm install pm2 -g