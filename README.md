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
├── Dockerfile (General Dockerfile of the main service)
├── requirements.txt (python requirements)
├── docker (Files related to build and operation of containers)
|   ├── ...
│   └── (docker subdirs, like db)
│      └── Scripts related to docker creation and operation of db service
└── src (the Django project files)
    ├── manage.py
    ├── pytest.ini
    └── ...
```

The code of the application is stored in `src`, and most of the docker-related files are in `docker`
subdir. Two main ones are in the root directory, docker-compose.yaml and Dockerfile. These
are the main docker files to operate at development.

Docker services for development
=========

The main docker-compose file has all the services to run at development

- test: Run the using tests, using [pytest](https://docs.pytest.org) and [pytest-django](https://pytest-django.readthedocs.io/)

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


- debug-server: Run a debug server, aimed to check interactivly the app through a browser. It
                    can be accessed at port 8000, and it will restart if the code of the application changes. It is using the django `runserver` command under the hood.
```
docker-compose up [-d] debug-server
```
- db: Database backend. It is started containing the data in the fixtures described in the code.


  Most of the changes in the code doesn't require restarting the services or rebuilding, but changes
in the DB do, like new fixtures or a new migration. Build all services with

```
    docker-compose build
```
