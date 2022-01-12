#!/bin/sh

cd components/tensorboard-controller

sed -i 's/docker-build: test/docker-build: #test/g' Makefile
sed -i 's/GOARCH=amd64/GOARCH=ppc64le/g' Dockerfile
sed -i 's/cd \/workspace\/tensorboard-controller/git config --global http.sslVerify false \&\& cd \/workspace\/tensorboard-controller/g' Dockerfile
sed -i 's/tensorflow\/tensorflow:2.1.0/quay.io\/ibm\/powerai:1.7.0-tensorflow-cpu-ubuntu18.04-py37-ppc64le/g' controllers/tensorboard_controller.go
sed -i 's/\/usr\/local\/bin\/tensorboard/\/opt\/anaconda\/envs\/wmlce\/bin\/tensorboard/g' controllers/tensorboard_controller.go

git config --global http.sslVerify false

sudo env "PATH=$PATH" make docker-build IMG=quay.io/ibm/${IMAGE}:${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
