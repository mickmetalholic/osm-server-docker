FROM debian:8
MAINTAINER yuanshen@corp.netease.com

ENV LANG C.UTF-8

# Install packages
RUN apt-get update -y
RUN apt-get install -y \
    wget \
    curl \
    unzip \
    build-essential \
    autoconf \
    libtool \
    gdal-bin \
    postgresql-9.4-postgis-2.1 \
    postgresql-contrib-9.4 \
    osm2pgsql \
    unifont \
    libmapnik-dev \
    apache2-dev \
    mapnik-utils \
    node-carto \
    apache2


# Install mod_tile
RUN cd /tmp && \
    wget https://github.com/openstreetmap/mod_tile/archive/e25bfdba1c1f2103c69529f1a30b22a14ce311f1.tar.gz -O mod_tile.tar.gz && \
    tar -xzf mod_tile.tar.gz && \
    mv mod_tile-e25bfdba1c1f2103c69529f1a30b22a14ce311f1 mod_tile && \
    cd mod_tile && \
    sh autogen.sh && \
    sh configure && \
    make && \
    make install && \
    make install-mod_tile


# Configure
## Configure renderd
RUN mkdir /var/run/renderd && \
    mkdir -p /var/lib/mod_tile
RUN echo "/usr/local/lib" >> /etc/ld.so.conf && \
    ldconfig
COPY config/renderd/renderd.conf.sed /tmp/
COPY config/renderd/renderd.init.sed /tmp/
RUN cp /tmp/mod_tile/debian/renderd.init /etc/init.d/renderd && \
    chmod a+x /etc/init.d/renderd && \
    sed --file /tmp/renderd.init.sed --in-place /etc/init.d/renderd && \
    sed --file /tmp/renderd.conf.sed --in-place /usr/local/etc/renderd.conf
## Configure apache2
RUN a2enmod headers && \
    echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/mods-available/tile.load && \
    ln -s /etc/apache2/mods-available/tile.load /etc/apache2/mods-enabled/
COPY config/apache2/000-default.conf.sed /tmp/
RUN sed --file /tmp/000-default.conf.sed --in-place /etc/apache2/sites-enabled/000-default.conf


# Clean up
RUN apt-get clean && rm -rf /tmp/*
RUN apt-get remove -y \
    wget \
    build-essential \
    autoconf \
    libtool


# Scripts
COPY config/pgsql/setLang.sql /
COPY config/pgsql/addExtensions.sql /
COPY config/run.sh /
ENTRYPOINT ["/bin/bash", "/run.sh"]


# Health check
HEALTHCHECK --start-period=10s \
  CMD curl --silent --fail 127.0.0.1:80/osm/0/0/0.png || exit 1


# Default command
CMD ["cli"]
