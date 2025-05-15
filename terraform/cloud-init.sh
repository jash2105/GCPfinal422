#!/bin/bash

# 1) Install OS packages
apt-get update -y
apt-get install -y python3 python3-pip git default-mysql-client

# 2) Clone your app
cd /opt
git clone https://github.com/jash2105/GCPfinal422.git
cd GCPfinal422

# 3) Python deps
pip3 install -r requirements.txt

# 4) Export DB credentials (injected by Terraform)
export DB_USER='gallery_user'
export DB_PASS='gallerypass123'
export DB_NAME='gallery_db'
export DB_HOST='10.200.0.2'    # ← Terraform output of sql_private_ip

# 5) Initialize the schema
mysql -h "$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" << 'EOSQL'
CREATE TABLE IF NOT EXISTS user (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS photo (
  PhotoID INT AUTO_INCREMENT PRIMARY KEY,
  CreationTime DATETIME NOT NULL,
  Title VARCHAR(255),
  Description TEXT,
  Tags TEXT,
  URL VARCHAR(255),
  ExifData JSON
);
EOSQL

# 6) Launch Flask
nohup python3 app.py > ~/flask.log 2>&1 &
