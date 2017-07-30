A Django project template for a RESTful Application using Docker
===

This is a template for using Docker when building and operating a Django RESTful application

Some opinionated ideas has been used. Please refer to this [blog post](https://wrongsideofmemphis.wordpress.com/2017/07/30/a-django-project-template-for-a-restful-application-using-docker/)
 for more info about the ideas and whys of this template, but in brief it aims to 
prepare a project to be easy to develop and deploy to production using Docker containers.


Description
=======

The application is a simple RESTful app that stores `tweets` and allow to create and retrieve them.
It is a simple [Django](https://www.djangoproject.com/) project that uses [Django REST framework](http://www.django-rest-framework.org/). The template makes use of Docker to create several containers, with
specific tasks aimed to development or to productionize the project.

It uses python3, Django 1.11 and requires Docker 17


Tree structure
========

```
├── README.md (this file)
├── docker-compose.yaml (general dockerfile description, aimed at development)
├── Dockerfile (General Dockerfile of the main server)
├── requirements.txt (python requirements)
├── environment.env (environment variables)
├── vendor (cache with generated wheels from dependencies)
├── deps (git submodules with embedded dependencies)
├── system-test
│   └── pytest.ini
│   └── requirements.txt (requirements for system tests)
│   └── healtcheck/
│   └── ...
├── docker (Files related to build and operation of containers)
│   └── (docker subdirs, like db or server)
│      └── Scripts related to docker creation and operation of that service
└── src (the Django project files)
    ├── manage.py
    ├── pytest.ini
    ├── healthcheck/
    └── ...
```

The code of the application is stored in `src`, and most of the docker-related files are in `docker`
subdir. Two main ones are in the root directory, docker-compose.yaml and Dockerfile. These
are the main docker files to operate at development.

The application includes some healtchecks that should be used to check if the service is healthy. At the
moment it just includes a check for the db, as well as a general check that the application is
responding, but more checks can be added under the smoketests view. The view is included as heathcheck
in the docker server, but it can be pulled externally as well in loadbalancers, etc.

environment.env stores environment variables that can set up the configuration. This include details
for the DB connection (host, user, password, etc), but also for other services. For example,
the environment variable SYSLOG_HOST points to the syslog facility to store logs. In this
file, it points to the `log` service container, but on deployment it should point to
the proper host.


Docker services for development
=========

The main docker-compose file has all the services to run at development

- *test*: Run the using tests, using [pytest](https://docs.pytest.org) and 
          [pytest-django](https://pytest-django.readthedocs.io/)

```
    docker-compose run test [pytest args]
```
  pytest is very powerful and allows a big variety of parameters, I recomend that everyone checks the docs and
learn a little bit about it. Some examples

```
    # Run all tests
    docker-compose run test
    # Recreate the DB
    docker-compose run test --create-db
    # Run tests that fits with stringexp
    docker-compose run test -k stringexp
    # Run failed tests from last run
    docker-compose run test --lf
``` 

  Some basic tests are added to the template. Note that the logs are directed to the console while running
the tests, and will be captured by pytest.


- *dev-server*: Run a dev server, aimed to check interactivly the app through a browser. It
                can be accessed at port 8000, and it will restart if the code of the application 
                changes. It is using the django `runserver` command under the hood.
```
docker-compose up [-d] dev-server
```
- *db*: Database backend. It is started containing the data in the fixtures described in the code.


  Most of the changes in the code doesn't require restarting the services or rebuilding, but changes
in the DB do, like new fixtures or a new migration. Build all services with

```
    docker-compose build
```

- *build-deps*: Precompile all dependencies into wheels and copy them in ./vendor. This is not
required, but can save time when rebuilding the containers often, to avoid compile the same code
over and over. Check the more detailed documentation in the ./vendor/README.md file.
  Note that dependencies embedded in ./deps won't be compiled (though their dependencies will be).
Check more details in the ./deps/README.md file. 

- *system-test*: Run system tests over the whole system. It send requests to the started system
and checks the results. It used pytest, so all the details from *test* works here.
  Remember to be sure to rebuild the *server* service before running them. Be also sure to check the
logs from the *log* service for insight while running them.

- *log*: A syslog facility that centralises all the logs. All the system will direct their logs 
to here, making convenient to check. You can check on the logs as they are generated running

```
docker-compose exec log tail -f /var/log/templatesite.log
```
  Remember that restarting the container will clean the file. This is convenient to not keep old logs
around, but it needs to keep in mind. Generallt, you don not need to bring down this container.

  Most important logs are the one generated by Django, that are prepend with "templatesite". A 
request id is added on each request helping group logs. This request id can be supplied externally
using the header X-REQUEST-ID, and it will be returned with the response.

- *metrics*: Report metrics in a [Prometheus](https://prometheus.io/) format. The Prometheus console 
can be checked in the port 9090. The metrics are exported in the server in the url /metrics

  A Django dashboard can be found at `http://localhost:9090/consoles/django.html`. This can be 
tweaked in the file ./docker/metrics/consoles/django.html

- *metrics-graph*: A Grafana container, as reference. This is presented directly from the Grafana 
standard container, and it should be pointed towards the metrics container 
in http://metrics:9090/. Follow the instructions in 
the [Grafana docs](http://docs.grafana.org/installation/docker/)
  Graphs and dashboards may be added, for example, querying:
```
    rate(django_http_requests_total_by_view_transport_method[1m])
```
To display all Django views. Be careful as the inherent non persistency of containers may destroy
your dashboards. This should be used only as example. Getting good dashboards is important for 
production, but not so much for development.


Docker services oriented to production
=========

At the moment, the main docker-composer runs the main container with a developer configuration

- *server*: Starts an http server serving the application. The application is served through
            uwsgi and nginx, and static files are cached through nginx.
            The service is available in http://localhost:8080/ when called through docker-compose.
            Please note that the container opens port 80.

  Once build, it can be used directly from the built container, though it need to connect to a valid db.
And fill the environment variables adequately. A simple test can be done in

```
    # Start the container djangodocker_server routing its port 80 to locahost:8080
    docker run -it --name test -p 8080:80 --env-file=your_environment.env templatesite
```
  The command option `-it` allows to stop the container hitting CTRL+C, as it connects to it, instead of having to use `docker stop test`. See [Docker documentation](https://docs.docker.com/engine/reference/commandline/run/#examples) for more details.

  The container will be configurable using environment variables. Check the available values in 
the environment.env file. These variables will need to point to the proper deployment values. In the
file they are defined for development purposes, but they won't work for a test outside that, as they
refer to docker-compose specific values.
  Also note that any changes to the contaniner won't be in effect until is rebuild.
