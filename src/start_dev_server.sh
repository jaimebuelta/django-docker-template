#!/bin/sh
python3 manage.py migrate -v 3
python3 manage.py runserver 0.0.0.0:80
