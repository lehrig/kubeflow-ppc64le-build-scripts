#!/bin/sh

sudo env "PATH=$PATH" make RELEASE_VERSION=${RELEASE} IMAGE_NAME=quay.io/ibm/${IMAGE} images

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
