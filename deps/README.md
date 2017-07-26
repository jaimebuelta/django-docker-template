Embedded dependencies
=====================
This directory is created to set direct dependencies that are not under pypi control or have more
manual installation. This is mainly aimed to modules that live in private git repos and are not
downloadable from PyPI, avoiding problems like requiring to pull from the repo with a ssh key
from inside the container.

The recommended way of dealing with them is to add them into this subdir git submodules and use
the Python [setuptool module](https://docs.python.org/3.6/distributing/index.html) (setup.py).

Note that dependencies here won't be installed from wheel, though their dependencies will be (if
done in the proper format, through a setup.py). That's to avoid problems with setup and cache the 
wrong version, with often happens while developing.
Remember to include the dependency in the requirements.txt file

An example of a module has been included (django-prometheus)

How to add a new submodule
==========================

    cd deps
    git submodule add https://github.com/foo

this creates the subdir foo with the submodule. The file .gitmodules will be updated and needs
to be tracked and commited.

How to update a submodule
==========================

Log into the submodule and set git to the desired commit/tag/branch

    cd deps/foo
    git checkout v7.5.0
    # or, for latest commit in current branch
    git pull

Then add the commit to the main repo, like a regular file

    cd ..
    git add foo
    git commit


If the submodule is updated
============================

and yours is not the proper version, it will appear as 

    git status
        modified:   foo (new commits)

Get the new commits with the command

    git submodule update --remote


NOTE: Working with git submodules is a little tricky. Feel free to add and modify this document.
