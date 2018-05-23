/CustomLog/a\
LoadTileConfigFile /usr/local/etc/renderd.conf\
ModTileRenderdSocketName /var/run/renderd/renderd.sock\
# Timeout before giving up for a tile to be rendered\
ModTileRequestTimeout 0\
# Timeout before giving up for a tile to be rendered that is otherwise missing\
ModTileMissingRequestTimeout 30
/#ServerName/a\
LoadModule headers_module modules/mod_headers.so
/DocumentRoot/a\
Header set Access-Control-Allow-Origin *
