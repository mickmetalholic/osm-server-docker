#!/bin/bash

basepath=$(cd `dirname $0`; pwd)/
PGSQLDIR=data/postgresql
GISDATADIR=data/gisData
RENDERCACHEDIR=data/cache
STYLESHEETDIR=data/openstreetmap-carto-2.29.1

STYLESHEETURI=https://github.com/gravitystorm/openstreetmap-carto/archive/v2.29.1.tar.gz
GISDATAURI=http://download.geofabrik.de/asia/china-latest.osm.pbf

DAEMONNAME=osm-server

# build docker daemon
build() {
  echo "Starting building the daemon "${DAEMONNAME}"..."
  docker build -t $DAEMONNAME .
}

# push docker daemon
push() {
  docker push $DAEMONNAME
}

# pull docker daemon
pull() {
  docker pull $DAEMONNAME
}

# make directories and download files
getdata() {
  echo "Starting downloading data..."
  # make directories
  mkdir -p $PGSQLDIR $GISDATADIR $RENDERCACHEDIR $STYLESHEETDIR
  # download stylesheet
  wget -O stylesheet.tar.gz $STYLESHEETURI
  tar -xzf stylesheet.tar.gz -C data
  rm stylesheet.tar.gz
  # download gis data
  wget -O data.pbf $GISDATAURI
  mv data.pbf $GISDATADIR/
  echo "Data download completed."
}

# initialize database and stylesheet
initialize() {
  docker run -it \
    -v ${basepath}${PGSQLDIR}:/var/lib/postgresql \
    -v ${basepath}${STYLESHEETDIR}:/root/stylesheet \
    $DAEMONNAME initialize
}

# import data
import() {
  docker run -it \
    -v ${basepath}${PGSQLDIR}:/var/lib/postgresql \
    -v ${basepath}${GISDATADIR}:/data \
    -v ${basepath}${STYLESHEETDIR}:/root/stylesheet \
    $DAEMONNAME import
}

# start services
start() {
  docker run -dit \
    -v ${basepath}${PGSQLDIR}:/var/lib/postgresql \
    -v ${basepath}${RENDERCACHEDIR}:/var/lib/mod_tile \
    -v ${basepath}${STYLESHEETDIR}:/root/stylesheet \
    -p 80:80 \
    $DAEMONNAME start
}

# debug
debug() {
  docker run -it \
    -v ${basepath}${PGSQLDIR}:/var/lib/postgresql \
    -v ${basepath}${GISDATADIR}:/data \
    -v ${basepath}${RENDERCACHEDIR}:/var/lib/mod_tile \
    -v ${basepath}${STYLESHEETDIR}:/root/stylesheet \
    $DAEMONNAME cli
}


# Execute the specified command sequence
for arg
do
  $arg;
done
exit 0
