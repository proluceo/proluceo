FROM postgres:15-bullseye

ENV POSTGRES_USER=proluceo PGUSER=proluceo
ENV PGPASSWD=choucroute POSTGRES_PASSWORD=choucroute
ENV PGDATA=/var/lib/postgresql/data/pgdata
ENV POSTGRES_HOST_AUTH_METHOD="pam pamservice=pg_auth"

# PAM service
ADD pg_auth /etc/pam.d/pg_auth

# Proluceo user
RUN useradd --no-log-init -d /tmp -s /bin/false -g 999 -p "$(openssl passwd -1 $PGPASSWD)" $POSTGRES_USER
ADD install.sh /install.sh
RUN /install.sh

# Rebuild locale
#RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ADD build/schema.sql /docker-entrypoint-initdb.d

#CMD docker-entrypoint.sh -c shared_preload_libraries=pg_cron.so -c cron.database_name=proluceo