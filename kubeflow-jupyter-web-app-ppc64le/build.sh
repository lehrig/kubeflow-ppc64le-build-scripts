#!/bin/sh

cd components/crud-web-apps/jupyter

sed -i 's/FROM node:12-buster-slim/FROM ppc64le\/node:12/g' Dockerfile

sudo make docker-build IMG=quay.io/ibm/${IMAGE} TAG=${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
