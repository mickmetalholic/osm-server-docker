#!/bin/sh


initdb() {
  echo "Initializing postgresql..."
  mkdir -p /var/lib/postgresql/9.4/main && chown -R postgres /var/lib/postgresql/
  su - postgres -c "/usr/lib/postgresql/9.4/bin/initdb --pgdata /var/lib/postgresql/9.4/main"
  ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /var/lib/postgresql/9.4/main/server.crt
  ln -s /etc/ssl/private/ssl-cert-snakeoil.key /var/lib/postgresql/9.4/main/server.key
  echo "Postgresql initialized"
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
  initdb
  startdb
  createuser
  createdb
  echo "Initialize finished!"
}

import() {
  echo "Importing data..."
  startdb
  osm2pgsql --slim -d gis -C 6000 --hstore -S /root/openstreetmap-carto-2.29.1/openstreetmap-carto.style /data/china-latest.osm.pbf
  echo "Finished importing data..."
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


# Unless there is a terminal attached wait until 5 seconds after boot
# when runit will have started supervising the services.
if ! tty --silent
  then
    _wait 5
  fi

# Execute the specified command sequence
for arg
do
  $arg;
done

# Unless there is a terminal attached don't exit, otherwise docker
# will also exit
if ! tty --silent
  then
  # Wait forever (see http://unix.stackexchange.com/questions/42901/how-to-do-nothing-forever-in-an-elegant-way).
  tail -f /dev/null
fi
