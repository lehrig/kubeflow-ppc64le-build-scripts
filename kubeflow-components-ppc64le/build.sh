#!/bin/sh

cd $CONTEXT_DIR

sudo chmod 777 /var/run/docker.sock

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo ./build_image.sh
