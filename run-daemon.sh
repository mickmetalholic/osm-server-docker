#!/bin/sh

basepath=$(cd `dirname $0`; pwd)/
PGSQLDIR=data/osm-postgresql
GISDATADIR=data/gisData
RENDERCACHEDIR=data/cache
GISDATAURI=http://download.geofabrik.de/asia/china-latest.osm.pbf
DAEMONNAME=osm-server

prebuild() {
  echo "Start doing some preperations..."
  # make directories
  mkdir -p $PGSQLDIR $GISDATADIR $RENDERCACHEDIR
  # download gis data
  wget -P ${basepath}${GISDATADIR} -O data.pbf $GISDATAURI
  # download and process stylesheet
  wget https://github.com/gravitystorm/openstreetmap-carto/archive/v2.29.1.tar.gz
  tar -xzf v2.29.1.tar.gz
  rm v2.29.1.tar.gz
  ./openstreetmap-carto-2.29.1/get-shapefiles.sh
  echo "Preperations completed, now you can build the daemon."
}

# build docker daemon
build() {
  echo "Starting build the daemon "${DAEMONNAME}"..."
  docker build -t $DAEMONNAME .
}

# intialize
initialize() {
  docker run -it -v ${basepath}${PGSQLDIR}:/var/lib/postgresql osm-server initialize
}

# import data
import() {
  docker run -it -v ${basepath}${PGSQLDIR}:/var/lib/postgresql -v ${basepath}${GISDATADIR}:/data osm-server import
}

# start services
start() {
  docker run -dit -v ${basepath}${PGSQLDIR}:/var/lib/postgresql -v ${basepath}${RENDERCACHEDIR}:/var/run/renderd -p 80:80 osm-server start
}

# debug
debug() {
  docker run -it -v ${basepath}${PGSQLDIR}:/var/lib/postgresql -v ${basepath}${GISDATADIR}:/data -v ${basepath}${RENDERCACHEDIR}:/var/run/renderd -p 80:80 osm-server cli
}


# Execute the specified command sequence
for arg
do
  $arg;
done
exit 0
