#!/bin/sh

git clone https://github.com/guimou/spark-on-openshift.git
cd spark-on-openshift/spark-images

sed -i 's/openjdk/docker.io\/ppc64le\/openjdk/g' spark3.Dockerfile
sed -i 's/sed -i.*list/echo "deb http:\/\/deb.debian.org\/debian buster main" >> \/etc\/apt\/sources.list/g' spark3.Dockerfile
sed -i 's/apt install -y/apt install -y --allow-unauthenticated/g' spark3.Dockerfile

sudo chmod 777 /var/run/docker.sock

export REGISTRY=quay.io/ibm
export TAG=s${SPARK_VERSION}-h${HADOOP_VERSION}_v${RELEASE}
export TARGET=${REGISTRY}/${IMAGE}:${TAG}

sudo docker build --build-arg hadoop_version=$HADOOP_VERSION --build-arg spark_version=$SPARK_VERSION -t ${TARGET} -f spark3.Dockerfile .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push ${TARGET}
