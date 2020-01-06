#!/bin/sh
# Docker entrypoint script.
echo "-----------------------"
echo " Environment Variables "
echo "-----------------------"
echo "DB_HOST: $DB_HOST"
echo "DB_USER: $DB_USER"
echo "APP_PORT: $APP_PORT"
echo "APP_HOSTNAME: $APP_HOSTNAME"

# Wait until Postgres is ready
while ! pg_isready -q -h $DB_HOST -p 5432 -U $DB_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

./prod/rel/prd/bin/prd eval StoeApi.Release.migrate

./prod/rel/prd/bin/prd start
