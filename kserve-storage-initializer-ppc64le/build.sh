#!/bin/sh

sudo env "PATH=$PATH" make docker-build-storageInitializer KO_DOCKER_REPO=quay.io/ibm STORAGE_INIT_IMG=${IMAGE}:${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
