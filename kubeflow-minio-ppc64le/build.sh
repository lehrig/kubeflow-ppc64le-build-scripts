#!/bin/sh

sudo docker pull docker.io/ibmcom/minio:${RELEASE}

sudo docker tag docker.io/ibmcom/minio:${RELEASE} quay.io/ibm/${IMAGE}:${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
