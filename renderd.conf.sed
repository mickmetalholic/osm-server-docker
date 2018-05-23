s/plugins_dir=\/usr\/lib\/mapnik\/input/plugins_dir=\/usr\/lib\/mapnik\/2.2\/input/
s/\(font_dir=\/usr\/share\/fonts\/truetype\)/\1\/unifont/
s/URI=\/osm_tiles\//URI=\/osm\//
s/XML=.*/XML=\/root\/openstreetmap-carto-2.29.1\/style.xml/
s/HOST=tile.openstreetmap.org/HOST=localhost/
/;\[renderd01\]/d
/;\[renderd02\]/d
/config options used by mod_tile, but not renderd/d
/;\[style2\]/d
