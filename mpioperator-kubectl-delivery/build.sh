#!/bin/sh

cd cmd/kubectl-delivery

sed -i 's/amd64/ppc64le/g' Dockerfile

sudo make build IMG=quay.io/ibm/${IMAGE} TAG=${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
