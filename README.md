# osm-server-docker

An Docker image building configurations for an [openstreetmap](https://www.openstreetmap.org/) server.

## Usage

```bash
# add excution permission
chmod a+x osm.sh
# download map data and stylesheet
./osm.sh prebuild
# import map data to database
./osm.sh import
# start service
./osm.sh start
```

Checkout http://127.0.0.1:80/osm/0/0/0.png, the server should be working.

The database and server cache are in folder ./data, so please do not remove it.

## Develop and debug

If you want to check inside the container, run

```bash
./osm.sh debug
```

to enter the container with bash.
