#!/bin/sh
/opt/code/db/start_postgres.sh
echo 'Migrating DB'
python3 manage.py migrate -v 3

echo 'Migrating to test DB'
# Copy the database, so we don't run migrations twice
su-exec postgres psql -c "CREATE DATABASE test_$POSTGRES_DB WITH TEMPLATE $POSTGRES_DB"

echo 'Loading fixtures'
# Note the fixtures are not loaded into the test DB
python3 manage.py loaddata ./*/fixtures/*

/opt/code/db/stop_postgres.sh
