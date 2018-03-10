FROM prom/prometheus:v2.2.0


ADD ./docker/metrics/prometheus.yaml /etc/prometheus/prometheus.yml
ADD ./docker/metrics/django.rules.yml /etc/prometheus/django.rules.yml
# Consoles can be found in localhost:9090/consoles/django.html
ADD ./docker/metrics/consoles/django.html  /usr/share/prometheus/consoles/

ENTRYPOINT []

# Strangely, replacing the entrypoint doesn't properly work. Deleting it and adding everything as CMD does the trick
CMD /bin/prometheus --config.file=/etc/prometheus/prometheus.yml --web.console.libraries=/usr/share/prometheus/console_libraries --web.console.templates=/usr/share/prometheus/consoles
