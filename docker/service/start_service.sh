#!/bin/sh
nginx
uwsgi --ini /opt/service/uwsgi.ini
