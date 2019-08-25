#!/bin/bash  -xv

echo  "${manager_ip}" # force rebuild

gsutil cp gs://dejima-prototype/swarm_join_token.txt /tmp/

echo "${crane_file}" > /home/ubuntu/crane.yml

CRANE_CONFIG=/home/ubuntu/crane.yml crane start postgres
sleep 5

CRANE_CONFIG=/home/ubuntu/crane.yml crane run peer bundle exec rake db:migrate
CRANE_CONFIG=/home/ubuntu/crane.yml crane rm --force peer

sleep 5

# add instance to swarm manager
$(grep "docker swarm join" /tmp/swarm_join_token.txt | xargs)