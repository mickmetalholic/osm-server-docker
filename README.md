# osm-server-docker

An Docker image building configurations for an [openstreetmap](https://www.openstreetmap.org/) server.

- stylesheet: openstreetmap-carto-2.29.1
- map data: china-latest.osm.pbf
- postgresql-9.4
- apache2


## Deploy

### Get the docker image

Download from dockerhub:

```bash
./osm.sh pull
```

Build image locally:

```bash
./osm.sh build
```

### Initialize

```bash
# create volume folders and download stylesheet and map data
./osm.sh getdata
# initialize stylesheet and database
./osm.sh initialize
# import data to database
./osm.sh import
```

### Start service

```bash
./osm.sh start
```

Checkout http://127.0.0.1:80/osm/0/0/0.png, and the server should be working.

The database and server cache are in folder ./data, so please do not remove it.


## Develop and debug

If you want to check inside the container, run

```bash
./osm.sh debug
```

to enter the container with bash.
