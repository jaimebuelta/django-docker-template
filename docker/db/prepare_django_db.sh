#!/bin/sh
./start_postgres.sh
python3 manage.py migrate --settings=templatesite.migration_settings
./stop_postgres.sh
# su-exec postgres postgres
