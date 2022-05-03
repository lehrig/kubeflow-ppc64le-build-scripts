#!/bin/sh

git clone https://github.com/guimou/spark-on-openshift.git
cd spark-on-openshift/spark-images

sed -i 's/apt install -y/apt install -y --allow-unauthenticated/g' pyspark.Dockerfile

sudo chmod 777 /var/run/docker.sock

export REGISTRY=quay.io/ibm
export TAG=s${SPARK_VERSION}-h${HADOOP_VERSION}_v${RELEASE}
export TARGET=${REGISTRY}/${IMAGE}:${TAG}
export BASE_IMAGE=${REGISTRY}/odh-spark-ppc64le:${TAG}

sudo docker build -t ${TARGET} -f pyspark.Dockerfile --build-arg base_img=${BASE_IMAGE} .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push ${TARGET}

