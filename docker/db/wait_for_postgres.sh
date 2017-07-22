#!/bin/bash
# wait-for-postgres.sh

set -e
echo "Waiting till up"

host="$1"
shift
cmd="$@"

until PGPASSWORD=$PG_PASSWORD psql -h "$host" -U "$PG_USER" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"
exec $cmd
