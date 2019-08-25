#!/bin/bash  -xv

echo  "${manager_ip}" # force rebuild

gsutil cp gs://dejima-prototype/swarm_join_token.txt /tmp/

echo "${crane_file}" > /home/ubuntu/crane.yml

CRANE_CONFIG=/home/ubuntu/crane.yml crane start postgres
sleep 15

CRANE_CONFIG=/home/ubuntu/crane.yml crane run peer bundle exec rake db:create
CRANE_CONFIG=/home/ubuntu/crane.yml crane run peer bundle exec rake db:migrate

# add instance to swarm manager
$(grep "docker swarm join" /tmp/swarm_join_token.txt | xargs)