#!/bin/sh

export BAZEL_VERSION=$(cat ml_metadata/tools/docker_server/Dockerfile | awk '/ENV BAZEL/{print $3}')

sed -i "s/DOCKER_IMAGE_REPO=.*/DOCKER_IMAGE_REPO=quay.io\/ibm\/${IMAGE}/g" ml_metadata/tools/docker_server/build_docker_image.sh
sed -i "s/DOCKER_IMAGE_TAG=.*/DOCKER_IMAGE_TAG=$RELEASE/g" ml_metadata/tools/docker_server/build_docker_image.sh

sed -i "s/python3-distutils/python3-distutils wget openjdk-8-jdk/g" ml_metadata/tools/docker_server/Dockerfile
sed -i "/ENV BAZEL_VERSION/a RUN wget https:\/\/oplab9.parqtec.unicamp.br\/pub\/ppc64el\/bazel\/ubuntu_18.04\/bazel_bin_ppc64le_$BAZEL_VERSION -O \/usr\/bin\/bazel && chmod +x \/usr\/bin\/bazel" ml_metadata/tools/docker_server/Dockerfile
sed -i '/RUN mkdir \/bazel/,/\    rm -f \/bazel\/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh/d' ml_metadata/tools/docker_server/Dockerfile
sed -i "s/--define=grpc_no_ares=true/--define=grpc_no_ares=true --jobs=8/g" ml_metadata/tools/docker_server/Dockerfile

sudo env "PATH=$PATH" ./ml_metadata/tools/docker_server/build_docker_image.sh

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
