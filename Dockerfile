FROM alpine:3.5

# Add requirements for python and pip
RUN apk add --update python3 pytest
RUN apk add --update postgresql-dev 

RUN mkdir -p /opt/code
WORKDIR /opt/code

ADD requirements.txt /opt/code

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

# Add code
ADD ./src/ /opt/code/
