#!/bin/sh

cd components/crud-web-apps/tensorboards

sed -i 's/FROM node/FROM ppc64le\/node/g' Dockerfile

sudo make docker-build IMG=quay.io/ibm/${IMAGE} TAG=${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
