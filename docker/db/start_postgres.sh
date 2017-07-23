#!/bin/sh
# Start gracefully postgres
su-exec postgres postgres &

set -e
echo "Waiting till up"

host="$1"
shift
cmd="$@"

until PGPASSWORD=$PGPASSWORD su-exec postgres psql -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done
