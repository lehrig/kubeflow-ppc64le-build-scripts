#!/bin/sh

export REGISTRY=quay.io/ibm

case "$TARGET_RUNTIME" in
   "anaconda") export RUNTIME_VERSION=$CUSTOM_CONDA_VERSION
   ;;
   "pandas") export RUNTIME_VERSION=$PANDAS_VERSION
   ;;
   "pytorch") export RUNTIME_VERSION=$PYTORCH_VERSION
   ;;
   "pytorch-cpu") export RUNTIME_VERSION=$PYTORCH_VERSION
   ;;
   "r") export RUNTIME_VERSION=$R_VERSION
   ;;
   "tensorflow") export RUNTIME_VERSION=$TENSORFLOW_VERSION
   ;;
   "tensorflow-cpu") export RUNTIME_VERSION=$TENSORFLOW_VERSION
   ;;
esac

export TAG=elyra$ELYRA_VERSION-py${PYTHON_VERSION}-${TARGET_RUNTIME}${RUNTIME_VERSION}
export IMAGE=$REGISTRY/${IMAGE}:${TAG}

sudo chmod 777 /var/run/docker.sock

docker build --squash --build-arg TARGET_RUNTIME=$TARGET_RUNTIME --build-arg NB_GID=0 --build-arg elyra_version=$ELYRA_VERSION --build-arg PYTHON_VERSION=$PYTHON_VERSION --build-arg conda_version=$CUSTOM_CONDA_VERSION --build-arg miniforge_patch_number=$MINIFORGE_PATCH_NUMBER --build-arg PANDAS_VERSION=$PANDAS_VERSION --build-arg PYTORCH_VERSION=$PYTORCH_VERSION --build-arg R_VERSION=$R_VERSION --build-arg TENSORFLOW_VERSION=$TENSORFLOW_VERSION -t $IMAGE -f Dockerfile .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push $IMAGE
