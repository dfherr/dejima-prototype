#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# SSH Authorized Keys
sudo rm -f /home/ubuntu/.ssh/authorized_keys
sudo mv /tmp/authorized_keys /home/ubuntu/.ssh/authorized_keys

# Docker
sudo apt-get -y update
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get -y update
sudo apt-get -y install docker-ce
sudo usermod -aG docker ubuntu

# pull the base image
sudo docker pull dfherr/dejima-prototype:latest
sudo docker pull dfherr/dejima-postgres:latest
