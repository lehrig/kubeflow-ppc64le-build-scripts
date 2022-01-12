#!/bin/sh

cd components/access-management

sed -i 's/GOARCH=amd64/GOARCH=ppc64le/g' Dockerfile
sed -i 's/RUN go mod download/RUN git config --global http.sslVerify false \&\& go mod download/g' Dockerfile

sudo make build IMG=quay.io/ibm/${IMAGE} TAG=${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
