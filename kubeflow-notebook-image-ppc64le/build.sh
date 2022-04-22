#!/bin/sh

export REGISTRY=quay.io/ibm
export TARGET=${REGISTRY}/${IMAGE}:${TAG}
export TAG=elyra${ELYRA_VERSION}-py${PYTHON_VERSION}
case "$TARGET_DOCKER_FILE" in
   "Dockerfile.base") export TAG=$TAG-base
   ;;
   "Dockerfile.minimal") export TAG=$TAG-min
   ;;
   "Dockerfile.scipy") export TAG=$TAG-scipy
   ;;  
   "Dockerfile.tensorflow-cpu")
     export TAG=$TAG-tensorflow-cpu${TENSORFLOW_VERSION}
     export TARGET_RUNTIME=tensorflow-cpu
     
   ;;
   "Dockerfile.tensorflow-gpu")
     export TAG=$TAG-tensorflow-gpu${TENSORFLOW_VERSION}
     export TARGET_RUNTIME=tensorflow
   ;;
esac


sudo chmod 777 /var/run/docker.sock

docker build --squash --build-arg NB_GID=0 --build-arg ELYRA_VERSION=$ELYRA_VERSION --build-arg PYTHON_VERSION=$PYTHON_VERSION --build-arg TENSORFLOW_VERSION=$TENSORFLOW_VERSION --build-arg TARGET_RUNTIME=$TARGET_RUNTIME -t $TARGET -f $TARGET_DOCKER_FILE .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push $TARGET
