#!/bin/bash
set -e

if [ ! -d /var/lib/influxdb/meta ]; then

  if [ -z ${INFLUX_PASS} ]; then
    INFLUX_PASS="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32;echo;)"
    echo "WARNING: User password not set. Generated password = $INFLUX_PASS"
  fi

  if [ -z ${INFLUX_ADMINPASS} ]; then
    INFLUX_ADMINPASS="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32;echo;)"
    echo "WARNING: Admin password not set. Generated password = $INFLUX_ADMINPASS"
  fi


  echo "Starting influxd..."
  INFLUXDB_HTTP_AUTH_ENABLED=0 /usr/bin/influxd &
  pid="$!"
  echo "Starting done..."


  INIT_QUERY="CREATE USER \"admin\" WITH PASSWORD '$INFLUX_ADMINPASS' WITH ALL PRIVILEGES"


  for i in {30..0}; do
    if $INFLUX_CMD "$INIT_QUERY" &> /dev/null; then
      break
    fi
    echo 'influxdb init process in progress...'
    sleep 1
  done


  INFLUX_CMD="/usr/bin/influx -username admin -password ${INFLUX_ADMINPASS} -execute "


  $INFLUX_CMD "create database telegraf"
  $INFLUX_CMD "create user admin with password '$INFLUX_ADMINPASS' with all privileges"
  $INFLUX_CMD "create user telegraf with password '$INFLUX_PASS'"
  $INFLUX_CMD 'GRANT ALL ON "telegraf" TO "telegraf"'


  if ! kill -s TERM "$pid" || ! wait "$pid"; then
    echo >&2 'influxdb init process failed. (Could not stop influxdb)'
    exit 1
  fi

fi

exec "$@"
