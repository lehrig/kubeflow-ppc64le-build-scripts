#!/bin/sh

export REGISTRY=quay.io/ibm
case "$TARGET_RUNTIME" in
   "tensorflow") export RUNTIME_VERSION=$TENSORFLOW_VERSION
   ;;
   "tensorflow-cpu") export RUNTIME_VERSION=$TENSORFLOW_VERSION
   ;;
esac
export TAG=py${PYTHON_VERSION}-${TARGET_RUNTIME}${RUNTIME_VERSION}
export TARGET=${REGISTRY}/${IMAGE}:${TAG}

sudo chmod 777 /var/run/docker.sock

docker build --build-arg NB_GID=0 --build-arg TENSORFLOW_VERSION=$TENSORFLOW_VERSION --build-arg PYTHON_VERSION=$PYTHON_VERSION --build-arg ELYRA_VERSION=$ELYRA_VERSION --build-arg TARGET_RUNTIME=$TARGET_RUNTIME -t $TARGET -f Dockerfile.all-in-one .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push $TARGET
