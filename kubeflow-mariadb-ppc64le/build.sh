#!/bin/sh

sudo docker pull docker.io/ibmcom/mariadb:${RELEASE}

sudo docker tag docker.io/ibmcom/mariadb:${RELEASE} quay.io/ibm/${IMAGE}:${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
