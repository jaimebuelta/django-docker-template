#!/bin/sh

echo 'Building dependencies'
mkdir -p /opt/wheels/
cd /opt/vendor

echo 'Building wheels from requirements'
pip3 wheel -r /opt/deps/requirements.txt --process-dependency-links

# Build go dependencies
for D in /opt/deps/*; do
    if [ -d "${D}" ]; then
        if [ -f "${D}/main.go" ]; then
            echo "Compiling go dependency in ${D}"
            cd ${D}
            go get
            make
            # Copy resulting executables to vendor dir
            find . -perm +111 -type f -exec cp {} /opt/vendor \; 
        fi
    fi
done

cd /opt/vendor

echo 'Done'

# Clean the direct dependencies to avoid issues with caches
for D in /opt/deps/*; do
    if [ -d "${D}" ]; then
        if [ -f "${D}/setup.py" ]; then
            echo "Removing dependency in ${D}"   # your processing here
            PKG_NAME=`python3 ${D}/setup.py --name`
            echo "Package name to remove ${PKG_NAME}"
            WHEEL=`python3 /opt/search_wheels.py $PKG_NAME -d /opt/vendor`
            echo "Deleting file $WHEEL"
            rm $WHEEL
        fi
    fi
done

echo "Wheels available: `ls /opt/vendor/*.whl`"
