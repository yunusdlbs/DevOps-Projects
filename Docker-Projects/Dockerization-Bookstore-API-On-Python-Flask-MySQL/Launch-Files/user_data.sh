#! /bin/bash

yum update -y
amazon-linux-extras install docker -y
systemctl restart docker
systemctl enable docker
usermod -aG docker ec2-user
newgrp docker
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cd /home/ec2-user
mkdir book-app && cd book-app
FOLDER="https://raw.githubusercontent.com/yunusdlbs/DevOps-Projects/main/Docker-Projects/Dockerization-Bookstore-API-On-Python-Flask-MySQL"
wget $FOLDER/requirements.txt
wget $FOLDER/bookstore-api.py
wget $FOLDER/Dockerfile
wget $FOLDER/docker-compose.yml
docker-compose up