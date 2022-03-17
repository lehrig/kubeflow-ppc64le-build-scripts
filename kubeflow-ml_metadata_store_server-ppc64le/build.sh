#!/bin/sh

export BAZEL_VERSION=$(cat ml_metadata/tools/docker_server/Dockerfile | awk '/ENV BAZEL/{print $3}')
conda install bazel==$BAZEL_VERSION -y

sed -i "s/DOCKER_IMAGE_REPO=.*/DOCKER_IMAGE_REPO=quay.io\/ibm\/${IMAGE}/g" ml_metadata/tools/docker_server/build_docker_image.sh
sed -i "s/DOCKER_IMAGE_TAG=.*/DOCKER_IMAGE_TAG=$RELEASE/g" ml_metadata/tools/docker_server/build_docker_image.sh

sed -i "s/--define=grpc_no_ares=true/--define=grpc_no_ares=true --jobs=8/g" ml_metadata/tools/docker_server/Dockerfile

sudo env "PATH=$PATH" ./ml_metadata/tools/docker_server/build_docker_image.sh

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
