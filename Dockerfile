FROM postgres:13
#ADD initdb.sql /docker-entrypoint-initdb.d

ENV POSTGRES_USER=proluceo PGUSER=proluceo
ENV PGPASSWD=choucroute POSTGRES_PASSWORD=choucroute
ENV PGDATA=/var/lib/postgresql/data/pgdata

ADD install.sh /install.sh
RUN /install.sh

ADD build/schema.sql /docker-entrypoint-initdb.d

#CMD docker-entrypoint.sh -c shared_preload_libraries=pg_cron.so -c cron.database_name=skiflow