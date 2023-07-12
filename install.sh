#!/bin/sh

# Set proxy during dev
#echo 'Acquire::http { Proxy "http://172.17.95.92:3142"; }' | tee -a /etc/apt/apt.conf.d/30proxy

apt-get update
apt-get install git postgresql-server-dev-15 build-essential curl unzip libcurl4-openssl-dev -y
mkdir /tmp/pre_install

## PG TUID
cd /tmp/pre_install
curl https://github.com/tanglebones/pg_tuid/archive/master.zip -o tuid.zip -L
unzip tuid.zip
cd pg_tuid-master/pg_c
make USE_PGXS=1
make USE_PGXS=1 install

## PG Cron
#cd /tmp/pre_install
#curl https://github.com/citusdata/pg_cron/archive/main.zip -o cron.zip -L
#unzip cron.zip
#cd pg_cron-main
#make USE_PGXS=1
#make USE_PGXS=1 install

## PG http
cd /tmp/pre_install
curl https://github.com/pramsey/pgsql-http/archive/master.zip -o http.zip -L
unzip http.zip
cd pgsql-http-master
make USE_PGXS=1
make USE_PGXS=1 install

## PG oxr
cd /tmp/pre_install
curl https://github.com/brunoenten/pg_oxr/archive/master.zip -o oxr.zip -L
unzip oxr.zip
cd pg_oxr-master
make USE_PGXS=1 install

## PG fsm
cd /tmp/pre_install
curl https://github.com/brunoenten/pg_fsm/archive/master.zip -o fsm.zip -L
unzip fsm.zip
cd pg_fsm-master
make USE_PGXS=1 install

## Cleanup
#apt-get remove git postgresql-server-dev-14 build-essential libreadline-dev zlib1g-dev  \
#     -y
#apt-get autoremove -y
#apt-get autoclean -y
cd /
rm -rf /tmp/pre_install
