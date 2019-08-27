Copy stacks files to manager:
`scp * ubuntu@managerip:`

Start docker logging stack:
`docker stack deploy --compose-file logging.yml logging`

Start dejima swarm (postgres is booted in dejima-peer-init.sh on instance startup):
`docker stack deploy --compose-file dejima-swarm.yml dejima`

Get service logs:
`docker service logs`

List services:
`docker service ls`

List nodes in swarm:
`docker node ls`

Tunnel kibana to localhost:
`ssh -L 5601:localhost:5601 ubuntu@managerip`