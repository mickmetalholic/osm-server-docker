#!/bin/sh

basepath=$(cd `dirname $0`; pwd)/
PGSQLDIR=data/osm-postgresql
GISDATADIR=data/gisData
RENDERCACHEDIR=data/cache
GISDATAURI=http://download.geofabrik.de/asia/china-latest.osm.pbf
STYLEDATAURI=https://github.com/gravitystorm/openstreetmap-carto/archive/v2.29.1.tar.gz

prebuild() {
  # make directories
  mkdir -p $PGSQLDIR $GISDATADIR $RENDERCACHEDIR
  # download gis data and stylesheet
  wget -P $GISDATADIR -O data.pbf $GISDATAURI
  wget $STYLEDATAURI
  cd $GISDATADIR
  ./get-shapefiles.sh
  cd ..
}

# build docker daemon
build() {
  docker build -t osm-server .
}

# intialize
initialize() {
  # initialize database
  docker run -it -v ${basepath}${PGSQLDIR}:/var/lib/postgresql osm-server initialize
}

# import data
import() {
  # import data to database
  docker run -it -v ${basepath}${PGSQLDIR}:/var/lib/postgresql -v ${basepath}${GISDATADIR}:/data osm-server import
}

# start container
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
