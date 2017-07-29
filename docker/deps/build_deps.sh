#!/bin/sh

echo 'Building dependencies'
mkdir -p /opt/wheels/
cd /opt/vendor

echo 'Building wheels from requirements'
pip3 wheel -r /opt/deps/requirements.txt --process-dependency-links

echo 'Done'

# Clean the direct dependencies to avoid issues with caches
for D in /opt/deps/*; do
    if [ -d "${D}" ]; then
        echo "Removing dependency in ${D}"   # your processing here
        PKG_NAME=`python3 ${D}/setup.py --name`
        echo "Package name to remove ${PKG_NAME}"
        WHEEL=`python3 /opt/search_wheels.py $PKG_NAME -d /opt/vendor`
        echo "Deleting file $WHEEL"
        rm $WHEEL
    fi
done

echo "Wheels available: `ls /opt/vendor/*.whl`"
