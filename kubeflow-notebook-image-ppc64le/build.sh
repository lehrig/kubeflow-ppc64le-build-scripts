#!/bin/sh

export REGISTRY=quay.io/ibm
export TAG=elyra${ELYRA_VERSION}-py${PYTHON_VERSION}
case "$TARGET_DOCKER_FILE" in
   "Dockerfile.base") export TAG=$TAG-base
   ;;
   "Dockerfile.minimal") export TAG=$TAG-min
   ;;
   "Dockerfile.scipy") export TAG=$TAG-scipy
   ;;  
   "Dockerfile.tensorflow") export TAG=$TAG-$(if [ "$SUPPORT_GPU" = true ]; then echo "tensorflow-gpu"; else echo "tensorflow-cpu"; fi)${TENSORFLOW_VERSION}
   ;;
   "Dockerfile.r") export TAG=$TAG-r
   ;;
   "Dockerfile.pytorch") export TAG=$TAG-$(if [ "$SUPPORT_GPU" = true ]; then echo "pytorch-gpu"; else echo "pytorch-cpu"; fi)${PYTORCH_VERSION}
   ;;
esac
export TAG=${TAG}-v${MINOR_RELEASE}
export TARGET=${REGISTRY}/${IMAGE}:${TAG}

sudo chmod 777 /var/run/docker.sock

docker build --squash --build-arg NB_GID=0 --build-arg ELYRA_VERSION=$ELYRA_VERSION --build-arg PYTHON_VERSION=$PYTHON_VERSION --build-arg TENSORFLOW_VERSION=$TENSORFLOW_VERSION --build-arg PYTORCH_VERSION=$PYTORCH_VERSION --build-arg SUPPORT_GPU=$SUPPORT_GPU --build-arg BASE_MINOR_RELEASE=$BASE_MINOR_RELEASE -t $TARGET -f $TARGET_DOCKER_FILE .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push $TARGET
