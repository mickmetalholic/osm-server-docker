#!/bin/bash


installstylesheet() {
  echo "Installing stylesheet ..."
  cd /root/stylesheet && \
    sh ./get-shapefiles.sh && \
    carto project.mml > style.xml
  echo "Stylesheet installed!"
}

initdb() {
  echo "Initializing postgresql..."
  mkdir -p /var/lib/postgresql/9.4/main && chown -R postgres /var/lib/postgresql/
  su - postgres -c "/usr/lib/postgresql/9.4/bin/initdb --pgdata /var/lib/postgresql/9.4/main"
  ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /var/lib/postgresql/9.4/main/server.crt
  ln -s /etc/ssl/private/ssl-cert-snakeoil.key /var/lib/postgresql/9.4/main/server.key
  echo "Postgresql initialized!"
}

startdb() {
  echo "Starting postgresql..."
  service postgresql start
  echo "Postgresql Started!"
}

createuser() {
  echo "Creating user root..."
  su - postgres -c "createuser root"
  echo "User root created!"
}

createdb() {
  echo "Creating database gis..."
  su - postgres -c "psql -f /setLang.sql"
  su - postgres -c "createdb -E UTF8 -O root gis"
  su - postgres -c "psql -s gis -f /addExtensions.sql"
  echo "Database gis created!"
}

initialize() {
  echo "Initializing..."
  installstylesheet
  initdb
  startdb
  createuser
  createdb
  echo "Initialize finished!"
}

import() {
  echo "Importing data..."
  startdb
  osm2pgsql --slim -d gis -C 6000 --hstore -S /root/stylesheet/openstreetmap-carto.style /data/data.pbf
  echo "Finished importing data!"
}

startrenderd() {
  echo "Starting renderd..."
  service renderd start
  echo "Renderd started!"
}

startapache2() {
  echo "Starting apache2..."
  service apache2 start
  echo "Apache2 started!"
}

start() {
  echo "Starting service..."
  startdb
  startrenderd
  startapache2
  echo "Service started!"
  tail -f /run.sh
}

cli() {
  echo "Running bash"
  /bin/bash
}


# Execute the specified command sequence
for arg
do
  $arg;
done
exit 0
