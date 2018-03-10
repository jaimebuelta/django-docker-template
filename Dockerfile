FROM alpine:3.7

ARG django_secret_key
ENV DJANGO_SECRET_KEY $django_secret_key

# Add requirements for python and pip
RUN apk add --update python3 pytest
RUN apk add --update postgresql-libs
RUN apk add --update curl
# Add envsubts
RUN apk add --update gettext
# Add nginx
RUN apk add --update nginx
RUN mkdir -p /run/nginx

RUN mkdir -p /opt/code
WORKDIR /opt/code

ADD requirements.txt /opt/code

# Try to use local wheels. Even if not present, it will proceed
ADD ./vendor /opt/vendor
ADD ./deps /opt/deps
# Only install them if there's any
RUN if ls /opt/vendor/*.whl 1> /dev/null 2>&1; then pip3 install /opt/vendor/*.whl; fi

# Add uwsgi and nginx configuration
RUN mkdir -p /opt/server
RUN mkdir -p /opt/static


# Add fix for stack for Python3.6
ADD ./docker/server/stack-fix.c /opt/server

# Some Docker-fu. In one step install the compile packages, install the
# dependencies and then remove them. That skims the image size quite
# sensibly.
RUN apk add --no-cache --virtual .build-deps \
  python3-dev build-base linux-headers gcc postgresql-dev \
    # Hack to fix the problem with runserver
    && gcc  -shared -fPIC /opt/server/stack-fix.c -o /opt/server/stack-fix.so \
    # Installing python requirements
    && pip3 install -r requirements.txt \
    && find /usr/local \
        \( -type d -a -name test -o -name tests \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' + \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
                | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                | sort -u \
                | xargs -r apk info --installed \
                | sort -u \
    )" \
    # Install uwsgi, from python
    && pip3 install uwsgi \
    && apk add --virtual .rundeps $runDeps \
    && apk del .build-deps


ADD ./docker/server/uwsgi.ini.template /opt/server
ADD ./docker/server/nginx.conf.template /opt/server
ADD ./docker/server/start_server.sh /opt/server

# Add code
ADD ./src/ /opt/code/

# Generate static files
RUN python3 manage.py collectstatic

EXPOSE 80
CMD ["/bin/sh", "/opt/server/start_server.sh"]
HEALTHCHECK CMD curl --fail http://localhost/healthcheck/
