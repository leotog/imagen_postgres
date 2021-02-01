#SCRIPT DE CONFIGURACION

#Arranco bd
/etc/init.d/postgresql start

#Creo usuario clave y la bd
psql --command "CREATE USER ${USER} WITH SUPERUSER PASSWORD '${PASS}';"
createdb -O pguser ${BBDD}

#Paro la instancia
/etc/init.d/postgresql stop

#Arranco de forma normal
exec /usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf
