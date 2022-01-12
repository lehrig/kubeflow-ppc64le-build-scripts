#!/bin/sh

export REGISTRY=quay.io/ibm

export TAG=base-py${PYTHON_VERSION}
export TARGET=$REGISTRY/${IMAGE}:${TAG}

sudo docker build --build-arg NB_GID=0 --build-arg PYTHON_VERSION=${PYTHON_VERSION} -t $TARGET -f Dockerfile.base .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push $TARGET
