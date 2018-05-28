#!/bin/sh

basepath=$(cd `dirname $0`; pwd)/
PGSQLDIR=data/osm-postgresql
GISDATADIR=data/gisData
RENDERCACHEDIR=data/cache
GISDATAURI=http://download.geofabrik.de/asia/china-latest.osm.pbf
DAEMONNAME=osm-server

prebuild() {
  echo "Starting doing some preperations..."
  # make directories
  mkdir -p $PGSQLDIR $GISDATADIR $RENDERCACHEDIR
  # download gis data
  wget -O data.pbf $GISDATAURI
  mv data.pbf $GISDATADIR/
  # download and process stylesheet
  wget https://github.com/gravitystorm/openstreetmap-carto/archive/v2.29.1.tar.gz
  tar -xzf v2.29.1.tar.gz
  rm v2.29.1.tar.gz
  cd openstreetmap-carto-2.29.1
  ./get-shapefiles.sh
  cd ..
  echo "Preperations completed, now you can build the daemon."
}

# build docker daemon
build() {
  echo "Starting building the daemon "${DAEMONNAME}"..."
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
  docker run -dit -v ${basepath}${PGSQLDIR}:/var/lib/postgresql -v ${basepath}${RENDERCACHEDIR}:/var/lib/mod_tile -p 80:80 osm-server start
}

# debug
debug() {
  docker run -it -v ${basepath}${PGSQLDIR}:/var/lib/postgresql -v ${basepath}${GISDATADIR}:/data -v ${basepath}${RENDERCACHEDIR}:/var/lib/mod_tile -p 80:80 osm-server cli
}


# Execute the specified command sequence
for arg
do
  $arg;
done
exit 0