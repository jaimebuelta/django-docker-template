#!/bin/sh
python3 manage.py migrate -v 3
# Preload hack to avoid sigfault
export LD_PRELOAD=/opt/server/stack-fix.so
python3 manage.py runserver 0.0.0.0:80
