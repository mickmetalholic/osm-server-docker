#!/bin/sh

PGSQLDIR=/data1/osm-postgresql
GISDATADIR=/data1/gisData
RENDERCACHEDIR=/data1/cache

# intialize database
initialize() {
  docker run -it -v $PGSQLDIR:/var/lib/postgresql osm-server initialize
}

# import data
import() {
  docker run -it -v $PGSQLDIR:/var/lib/postgresql -v $GISDATADIR:/data osm-server import
}

# start container
start() {
  docker run -dit -v $PGSQLDIR:/var/lib/postgresql -v $RENDERCACHEDIR:/var/run/renderd -p 80:80 osm-server start
}

# debug
debug() {
  docker run -it -v $PGSQLDIR:/var/lib/postgresql -v $GISDATADIR:/data -v $RENDERCACHEDIR:/var/run/renderd -p 80:80 osm-server cli
}

# Execute the specified command sequence
for arg
do
  $arg;
done
exit 0
