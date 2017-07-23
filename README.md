A Django project template for a RESTful Application using Docker
===

This is a template for using Docker when building and operating a Django RESTful application

Some opinionated ideas has been used. Please refer to this blog post for more info about the
ideas and whys of this template, but in brief it aims to prepare a project to be easy to
develop and deploy to production using Docker containers.


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
├── docker (Files related to build and operation of containers)
│   └── (docker subdirs, like db or server)
│      └── Scripts related to docker creation and operation of that service
└── src (the Django project files)
    ├── manage.py
    ├── pytest.ini
    ├── smoketests
    └── ...
```

The code of the application is stored in `src`, and most of the docker-related files are in `docker`
subdir. Two main ones are in the root directory, docker-compose.yaml and Dockerfile. These
are the main docker files to operate at development.

The application includes some smoketest that should be used to check if the service is healthy. At the
moment it just includes a check for the db, as well as a general check that the application is
responding, but more checks can be added under the smoketests view. The view is included as heathcheck
in the docker server, but it can be pulled externally as well in loadbalancers, etc.


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

Docker services oriented to production
=========

At the moment, the main docker-composer runs the main container with a developer configuration

- *server*: Starts an http server serving the application. The application is served through
            uwsgi and nginx, and static files are cached through nginx.
            The service is available in http://localhost:8080/ when called through docker-compose.
            Please note that the container opens port 80.

  Once build, it can be used directly from the built container, though it need to connect to a valid db. A simple test can be done in

```
    # Start the container djangodocker_server routing its port 80 to locahost:8080
    docker run -it --name test -p 8080:80 djangodocker_server
```
  The command option `-it` allows to stop the container hitting CTRL+C, as it connects to it, instead of having to use `docker stop test`. See [Docker documentation](https://docs.docker.com/engine/reference/commandline/run/#examples) for more details.

  The container will be configurable using environment variables.
  Also note that any changes to the contaniner won't be in effect until is rebuild.
