FROM alpine:3.7

# Add the proper env variables for init the db
ARG POSTGRES_DB
ENV POSTGRES_DB $POSTGRES_DB
ARG POSTGRES_USER
ENV POSTGRES_USER $POSTGRES_USER
ARG POSTGRES_PASSWORD
ENV POSTGRES_PASSWORD $POSTGRES_PASSWORD
ARG POSTGRES_PORT

# secret key for Django
ARG django_secret_key
ENV DJANGO_SECRET_KEY $django_secret_key

# For usage in migrations, etc
ENV POSTGRES_HOST localhost

RUN apk --update add \
    bash nano curl su-exec\
    python3 \
    postgresql postgresql-contrib postgresql-dev && \
    rm -rf /var/cache/apk/*

ENV LANG en_US.utf8
ENV PGDATA /var/lib/postgresql/data


# ENTRYPOINT ["/postgres-entrypoint.sh"]

EXPOSE $POSTGRES_PORT
VOLUME /var/lib/postgresql/data


# Adding our code
RUN mkdir -p /opt/code
RUN mkdir -p /opt/data
# Store the data inside the container, as we don't care for
# persistence
ENV PGDATA /opt/data
WORKDIR /opt/code

RUN mkdir -p /opt/code/db
WORKDIR /opt/code/db
# Add postgres setup
ADD ./docker/db/postgres-setup.sh /opt/code/db/
RUN ./postgres-setup.sh

# Install our code to run migrations and prepare DB
WORKDIR /opt/code
ADD requirements.txt /opt/code

# Try to use local wheels. Even if not present, it will proceed
ADD ./vendor /opt/vendor
ADD ./deps /opt/deps
# Only install them if there's any
RUN if ls /opt/vendor/*.whl 1> /dev/null 2>&1; then pip3 install /opt/vendor/*.whl; fi

# Some Docker-fu. In one step install the compile packages, install the
# dependencies and then remove them. That skims the image size quite
# sensibly.
RUN apk add --no-cache --virtual .build-deps \
  python3-dev build-base linux-headers gcc \
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
    && apk add --virtual .rundeps $runDeps \
    && apk del .build-deps

# Need to import all the code, due tangled dependencies
ADD ./src/ /opt/code/
# Add all DB commanda
ADD ./docker/db/* /opt/code/db/

# get migrations, etc, ready
RUN /opt/code/db/prepare_django_db.sh

CMD ["su-exec",  "postgres", "postgres"]
