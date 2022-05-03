#!/bin/sh

git clone https://github.com/GoogleCloudPlatform/spark-on-k8s-operator.git
cd spark-on-k8s-operator
git checkout ${RELEASE}

sed -i 's/golang/docker.io\/ppc64le\/golang/g' Dockerfile.rh
sed -i 's/amd64/ppc64le/g' Dockerfile.rh 

sudo chmod 777 /var/run/docker.sock

export REGISTRY=quay.io/ibm
export TARGET=${REGISTRY}/${IMAGE}:${RELEASE}

export SPARK_TAG=s${SPARK_VERSION}-h${HADOOP_VERSION}_v1.0.0
export SPARK_IMAGE=${REGISTRY}/odh-spark-ppc64le:${SPARK_TAG}

export DOCKER_BUILDKIT=1
sudo docker build --build-arg SPARK_IMAGE=${SPARK_IMAGE} -t ${TARGET} -f Dockerfile.rh .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push ${TARGET}

