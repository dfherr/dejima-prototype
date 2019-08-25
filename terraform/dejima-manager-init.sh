#!/bin/bash  -xv

# external_manager_ip=$(curl -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
# docker swarm init --advertise-addr $external_manager_ip

docker swarm init
docker swarm join-token worker >> /tmp/swarm_join_token.txt

gsutil cp /tmp/swarm_join_token.txt gs://dejima-prototype/