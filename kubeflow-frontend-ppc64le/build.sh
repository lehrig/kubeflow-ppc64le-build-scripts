#!/bin/sh
sed -i 's/FROM node:14\.18\.2 as build/FROM node:14\.18\.2-alpine as build/g' frontend/Dockerfile

cd frontend
sudo docker build --no-cache -t quay.io/ibm/${IMAGE}:${RELEASE} -f Dockerfile .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
