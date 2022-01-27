#!/bin/sh
sed -i 's/FROM node:14\.18\.2/FROM node:14\.18\.2-alpine/g' frontend/Dockerfile

sudo docker build -t quay.io/ibm/${IMAGE}:${RELEASE} -f frontend/Dockerfile .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
