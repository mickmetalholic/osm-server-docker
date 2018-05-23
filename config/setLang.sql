update pg_database set datallowconn = TRUE where datname = 'template0';
\c template0
update pg_database set datistemplate = FALSE where datname = 'template1';
drop database template1;
create database template1 with encoding = 'UTF8' LC_CTYPE = 'C.UTF-8' LC_COLLATE = 'C.UTF-8' template = template0;
update pg_database set datallowconn = TRUE where datname = 'template1';
\c template1
update pg_database set datallowconn = FALSE where datname = 'template0';
