#!/bin/sh
nginx
uwsgi --ini /opt/server/uwsgi.ini
