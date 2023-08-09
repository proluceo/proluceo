#!/bin/sh

# Set proxy during dev
#echo 'Acquire::http { Proxy "http://172.20.75.97:3142"; }' | tee -a /etc/apt/apt.conf.d/30proxy

apt-get update
apt-get install git postgresql-server-dev-15 build-essential curl unzip libcurl4 libcurl4-openssl-dev libphonenumber8 libphonenumber-dev ca-certificates libpam0g libpam-dev -y --no-install-recommends
mkdir /tmp/pre_install

## PG TUID
#cd /tmp/pre_install
#curl https://github.com/tanglebones/pg_tuid/archive/master.zip -o tuid.zip -L
#unzip tuid.zip
#cd pg_tuid-master/pg_c
#make USE_PGXS=1
#make USE_PGXS=1 install

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

## PG libphonenumber
cd /tmp/pre_install
curl https://github.com/blm768/pg-libphonenumber/archive/master.zip -o libphonenumber.zip -L
unzip libphonenumber.zip
cd pg-libphonenumber-master
make USE_PGXS=1 install

## Oauth2
cd /tmp/pre_install
curl https://github.com/please-openit/pam-oauth2/archive/master.zip -o pam-oauth2.zip -L
unzip pam-oauth2
cd pam-oauth2-master
curl https://github.com/zserge/jsmn/archive/master.zip -o jsmn.zip -L
rmdir jsmn
unzip jsmn.zip
mv jsmn-master jsmn
make
make install

## Cleanup
apt-get remove git postgresql-server-dev-15 build-essential curl unzip libcurl4-openssl-dev libphonenumber-dev ca-certificates libpam0g-dev -y
apt-get autoremove -y
apt-get autoclean -y
cd /
rm -rf /tmp/pre_install
