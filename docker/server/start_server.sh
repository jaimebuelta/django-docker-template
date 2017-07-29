#!/bin/sh
# Allow to define dollars in the templates
export DOLLAR='$'
envsubst < /opt/server/nginx.conf.template > /etc/nginx/conf.d/default.conf
envsubst < /opt/server/uwsgi.ini.template > /opt/server/uwsgi.ini
nginx
uwsgi --ini /opt/server/uwsgi.ini
