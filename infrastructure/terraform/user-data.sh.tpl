#!/bin/bash

# Wait for everything to be ready
sleep 15

# User data runs as root
cd /home/ubuntu

# Cd to correct folder
cd packer-terraform-actions/infrastructure/website/nodejs20-se-test-app-2025/app

# DB connection env var
export DB_HOST=mongodb://${db_ip}:27017/posts

# Install dependencies
sudo npm install

# Seed database
node seeds/seed.js

# Start app
pm2 start app.js