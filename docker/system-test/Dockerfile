FROM alpine:3.7

RUN apk add --update python3 py3-pip pytest
RUN mkdir -p /opt/system-test

ADD ./system-test/requirements.txt /opt/system-test

WORKDIR /opt/system-test

# So far, no compilation requirements
RUN pip3 install -r requirements.txt

ADD ./system-test/ /opt/system-test
