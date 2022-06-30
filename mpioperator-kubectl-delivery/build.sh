#!/bin/sh

sed -i 's/amd64/ppc64le/g' cmd/kubectl-delivery/Dockerfile

export TARGET=quay.io/ibm/${IMAGE}:${RELEASE}

sudo chmod 777 /var/run/docker.sock

sudo docker build --squash -t ${TARGET} -f cmd/kubectl-delivery/Dockerfile .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push ${TARGET}
