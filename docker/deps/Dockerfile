FROM alpine:3.7
RUN mkdir -p /opt/vendor
WORKDIR /opt/vendor
RUN apk update
# Basic python usage
RUN apk add python3
RUN apk add py3-pip 

# Required for compiling
RUN apk add python3-dev build-base linux-headers gcc postgresql-dev
RUN pip3 install cython wheel

ADD ./deps /opt/deps
RUN mkdir -p /opt/vendor
ADD requirements.txt /opt/deps
ADD ./docker/deps/build_deps.sh /opt/
ADD ./docker/deps/copy_deps.sh /opt/
ADD ./docker/deps/search_wheels.py /opt/

WORKDIR /opt/
RUN ./build_deps.sh
