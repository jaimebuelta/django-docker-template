#!/bin/sh
/opt/code/db/start_postgres.sh
python3 manage.py migrate --settings=templatesite.migration_settings
python3 manage.py test -v 3 --settings=templatesite.migration_settings --keepdb
/opt/code/db/stop_postgres.sh
# su-exec postgres postgres
