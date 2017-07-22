#!/bin/sh
/opt/code/db/start_postgres.sh
echo 'Migrating DB'
python3 manage.py migrate --settings=templatesite.migration_settings

echo 'Migrating to test DB'
# To do so, we run an empty test. This can be replaced to dump the DB and 
# create it as test, if the DB magration takes too long
python3 manage.py test -v 3 --settings=templatesite.migration_settings --keepdb -p blabla

echo 'Loading fixtures'
# Note the fixtures are not loaded into the test DB
python3 manage.py loaddata --settings=templatesite.migration_settings ./*/fixtures/*

/opt/code/db/stop_postgres.sh
