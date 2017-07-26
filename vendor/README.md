Pregenerated wheels
===================
The dependencies can be precompiled in wheels to avoid time compiling while building the service.

The service `build-deps` is doing that. Collect all dependencies from requirements.txt file, downloading them,
and compiling them as python wheel files. The wheel files are there shared with the host in the ./vendor
directory

**This step is optional. The container should build with an empty ./vendor directory**

Some extra dependencies (like compilers, dev packages, etc) may be required in `docker/deps/Dockerfile` 
to allow the creation of the wheel.

To generate the dependencies, run

    docker-compose up --build build-deps

Remember to run it again if you change the recipe (like adding a new dependency), which will rebuild all dependencies. 
The generation of wheels will be performed on deployment using the cache.

If you want to force the rebuild, run

    docker-compose build --no-cache build-deps
    docker-compose up build-deps

Note that direct dependencies in ./deps won't generate a wheel*, but their dependencies will. This is
done to ensure they are always installed fresh, as they are likely to be changed often. See more info
in ./deps/README.md

* (The wheel will be generated internally to ensure compilation of dependencies, but it will be deleted) *
