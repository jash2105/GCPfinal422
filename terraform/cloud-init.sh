#!/bin/bash

# Update and install packages
apt-get update -y
apt-get install -y python3 python3-pip git

# Clone your actual repo
cd /opt
git clone https://github.com/jash2105/GCPfinal422.git
cd GCPfinal422

# Install Python dependencies
pip3 install -r requirements.txt

# Export DB env vars
export DB_USER='gallery_user'
export DB_PASS='gallerypass123'
export DB_NAME='gallery_db'
export DB_HOST='10.10.0.3'

# Run the app
nohup python3 app.py > /opt/flask.log 2>&1 &
