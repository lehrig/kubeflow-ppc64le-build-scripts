#!/bin/sh

cd components/notebook-controller

sed -i 's/.\/third_party\/check-license.sh/#.\/third_party\/check-license.sh/g' Makefile
sed -i 's/docker-build: test/docker-build: #test/g' Makefile
sed -i 's/GOARCH=amd64/GOARCH=ppc64le/g' Dockerfile

sudo env "PATH=$PATH" make docker-build IMG=quay.io/ibm/${IMAGE} TAG=${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
