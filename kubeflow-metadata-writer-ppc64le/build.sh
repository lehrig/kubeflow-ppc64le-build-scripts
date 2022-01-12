#!/bin/sh

# docker run -ti -v /var/run/docker.sock:/var/run/docker.sock quay.io/ibm/osuosl-ubuntu-base-image-ppc64le:V1.0.0
# git clone https://github.com/kubeflow/pipelines.git && cd pipelines
# git checkout ${RELEASE}

sed -i '/^RUN python3 -m pip install -r.*/i RUN mkdir ~/.pip/' backend/metadata_writer/Dockerfile
sed -i '/^RUN mkdir ~\/.pip.*/a RUN echo "[global]" >> ~/.pip/pip.conf' backend/metadata_writer/Dockerfile
sed -i '/^RUN echo \"\[global\]\".*/a RUN echo "extra-index-url = https://repo.fury.io/mgiessing" >> ~/.pip/pip.conf' backend/metadata_writer/Dockerfile

sudo docker build -t quay.io/ibm/${IMAGE}:${RELEASE} -f backend/metadata_writer/Dockerfile .

sudo docker images

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
