# Dejima prototype

This project is a prototype for the Dejima data sharing architecture. It uses a Ruby on Rails API as the distributed coordination layer on top of a postgresql database, which is modified with plpgsql & plsh sql triggers to emulate BX behavior.

Due to emulating BX behavior using sql triggers, the prototype has several limitations:

* It has no access to reads (required for consistency)
* It has no access to transaction numbers (required for consistency, especially detecting staleness)
* It can't handle complex transformations across dependend dejima groups. This needs an additional transformation response from a peer, which is connecting two dependent dejima groups.
* Database users are used to determine the origin of a request. The user "dejima" is locked for coordination layer requests, while every other user makes regular updates
* Updates are translated to insert/delete querries, which might result in severe performance issues (reindexing, data fragementation)

The prototype uses a very simple example of three peers. A bank, an insurance and the government. These three peers share person registration data: firstname, lastname, birthdate, address and phone number. The government knows about all this data, while the insurance does not know the phone number and the bank does not know the birthdate.

The rails api code is in the subdirectory "peer" and contains the code for three different peer-types (bank, insurance, government). The same code can also be used to launch very simple clients to make database updates. These are not necessary for the prototype, but convenient for manual testing. Which type is launched is controlled via the environment variable `PEER_TYPE`, which takes the values `bank`, `government` and `insurance`. If the application is launched as "peer" or "client" is controlled via the environment variable `RAILS_ENV` variable. `RAILS_ENV=client_development` will start the application as a client in the development environment, while `RAILS_ENV=peer_development` will start it as a peer in the development environment.

This is all preconfigured for easy-use in the orchestration file (crane.yml)[crane.yml]. See details further down in How to use.


## Prototype setup

The prototype runs completely in docker containers. We used crane for orchestration.

Therefore you need to install:

* [Docker](https://docs.docker.com/install/) Version >= 1.13
* [Crane](https://www.crane-orchestration.com/installation) Version 3.5.x. the free version is sufficient

## Building the docker images

While rebuilding the images is not necessary for regular development (see Configuration below), it is necessary to rebuild the images to modify the installed packages inside the images.

The images are hosted on Dockerhub and can be built locally. The peer [Dockerfile](Dockerfile) is in the root directory. The Dockerfile for the modified postgres database is in [docker-postgres/Dockerfile](docker-postgres/Dockerfile). Both images use the very small alpine base images. A [Makefile](Makefile) is provided to easily update the images. Running `make build` in the project root will rebuild the docker image locally.

## How to use

The project can be easily used with the crane orchestration tool and the provided [orchestration file](crane.yml). It provides an easy configuration format for starting docker container.

Simply boot up the peers and possibly clients in *seperate* shells using the following commands:

```
crane run bank-peer
crane run bank-client
crane run gov-peer
crane run gov-client
crane run insurance-peer
crane run insurance-client
```

You do not have to boot all of them. E.g. just running `gov-peer` and `bank-peer` will create a simple dejima network with one dejima group.

### Remarks

* *Wait between starting peers*. Starting peers will trigger the peer detection algorithm and will not work, if another server is starting, but not yet ready to respond. Simply starting it again once the other peer is ready to respond solves this issue. A retry mechanism isn't implemented. Startup might be slow, because TCP connections to unreachable peers have to timeout.
* The peers will automatically start their postgres databases in the background and apply all necessary database changes. Each client/peer has one common database (i.e. `bank-postgres`, `gov-postgres`, `insurance-postgres`)
* Each peer, client and database per type share one virtual network, while all peers are connected within a seperate network. These networks are completely isolated from each other and the host system unless configured otherwise.
* Application logs are added to the default docker logs and will be output to stdout on a docker container running in the forground. Use `docker logs -f container_name` to tail logs of a container running in the background (e.g. the database).


### Configuration

* With the provided configuration the bank-client is reachable from the host system using port 3000. This can be configured in the crane.yml with the  `publish` option. See [crane.yml](crane.yml) `bank-client` configuration. Example: `publish: ["80:3000"]` would link the port 3000 of the container to port 80 of the host system running docker.
* The provided configuration mounts the peer code of the host system into the docker container using the `volume` option. This means all changes to the code on the host system are used the the container without rebuilding the image. Just edit the files inside of peer folder and the changes will be used by the docker containers. *The server might require a restart for some changes to take affect.*
* The `rm` option will automatically remove a container when stopped and create a new container on the next startup. This is usually very handy, but might be hurtful if you need to look at a container after it failed. Remove the `rm` option in the crane.yml to disable this.
* You can simply append commands to crane. E.g. `crane run bank-peer bash` will create the bank-peer container with all configured settings and open a bash shell inside the container. Rspectively `crane run bank-peer rails console` will open the rails console inside the container.

### Reseting the databases

The databases are automatically started in the background, when a peer or client is launched and not stopped, when stopped their connected peers/client. To reset the database and wipe all data simply remove the database container, e.g. to remove the banks database use:

```
crane rm --force bank-postgres
```

The database will automatically be restarted and setup the next time either `bank-client` or `bank-peer` is started using crane.

## Peer code structure

The peer code uses the default Ruby on Rails architecture with some tweaks for the dejima architecture. The environment variable `RAILS_ENV` controls client/peer behavior and development/test/production environment. The environment variable `PEER_TYPE` control bank/government/insurance types.

Here is an overview of the most important files:

* [app/controllers/dejima_controller.rb](peer/app/controllers/dejima_controller.rb) provides API endpoints reachable per http. It provides an endpoint for creating users for the clients and all communication endpoints for the peers.
* [config/routes.rb](peer/config/routes.rb) configures the links between HTTP URLs and controller methods.
* [app/libs/](peer/app/libs/) has the `dejima_proxy.rb` this is responsible for the outgoing requests to other peers and the `dejima_utils.rb`, which has the code for the dejima framework algorithms.
* [app/models](peer/app/models/) has the ORM ckasses for the database access.
* [db/migrate](peer/db/migrate/) has the code for creating database tables and other modifications. Only the tables for the configured `PEER_TYPE` will be created. These files will be run on startup and only applied once.
* [lib/dejima_sql/](peer/lib/dejima_sql) has the plpgsql & plsh sql triggers from [Van Dang https://github.com/dangtv/BIRDS](https://github.com/dangtv/BIRDS)
* [config/initializers/dejima_create_peer_groups.rb](peer/config/initializers/dejima_create_peer_groups.rb) initiates the peer group detection algorithm on startup.

## License

[MIT](LICENSE)

Copyright (c) 2019 Dennis-Florian Herr

Created as part of my master thesis @ TUM and the Big Data Engineering Lab of Osaka University
