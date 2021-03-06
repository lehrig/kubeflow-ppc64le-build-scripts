#!/bin/sh

cd components/profile-controller

sed -i 's/GOARCH=amd64/GOARCH=ppc64le/g' Dockerfile

sudo make build IMG=quay.io/ibm/${IMAGE} TAG=${RELEASE}


set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
