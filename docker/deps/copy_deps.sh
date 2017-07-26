#!/bin/sh
echo 'Deleting wheels and copy new ones'
rm /opt/ext_vendor/*.whl
echo "Dependencies are created at build. Run build --no-cache to recreate"
cp /opt/vendor/* /opt/ext_vendor

