#DESDE UBUNTU
FROM ubuntu:14.04
MAINTAINER Leo "leo@leo.com"

#Agrego pgp de postgres
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

#Agrego repo postgresql
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

#Actualizo repos
RUN apt-get update && apt-get -y -q install python-software-properties software-properties-common \
 && apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

#######Cambio al usuario postgres que se crea al instalar
######USER postgres

######Creo un usuario pguser con clave secret y una base de datos pgdb
#####RUN /etc/init.d/postgresql start \
##### && psql --command "CREATE USER pguser WITH SUPERUSER PASSWORD 'secret';" \
##### && createdb -O pguser pgdb

#Cambio al usuario ROOT
USER root

#Permito conexiones remotas a postgres
RUN echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/9.3/main/pg_hba.conf

#Permito acceso desde cualquier IP
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

#Expongo el puerto de la base de datos
EXPOSE 5432

#Creo directorio en var run y le doy permiso al usuario postgres
RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

#Creo volumenes para guardar backup de la configuracion, logs, base de datos y poder acceder desde afuera del contenedor
VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

#Copio el ficher entrypoint.sh y doy permisos de ejecucion
ADD entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

#Cambio al usuario postgres
USER postgres

###########Indico comando que se va a ejecutar al arrancar el contenedor
######### Arranco postgres con la configuracion indicada
#######CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]

#Creo las tres variables para el usuario clave y bd
ENV PASS=secret
ENV BBDD=pgdb
ENV USER=pguser

#Ejecuto el script entrypoint.sh
CMD /usr/local/bin/entrypoint.sh
