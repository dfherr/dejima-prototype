#!/bin/bash  -xv

gsutil cp gs://dejima-prototype/swarm_join_token.txt /tmp/

# add instance to swarm manager
$(grep "docker swarm join" /tmp/swarm_join_token.txt | xargs)