#!/bin/sh

cd cmd/kubectl-delivery

sed -i 's/amd64/ppc64le/g' Dockerfile

export TARGET=quay.io/ibm/${IMAGE}:${RELEASE}

sudo chmod 777 /var/run/docker.sock

sudo docker build --squash -t ${TARGET} .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push ${TARGET}
