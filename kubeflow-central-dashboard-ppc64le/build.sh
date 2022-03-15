#!/bin/sh

cd components/centraldashboard

cat >> install-chromium.txt <<'EOF'
RUN echo deb http://us.ports.ubuntu.com/ubuntu-ports/ bionic universe >> /etc/apt/sources.list && \
    echo deb http://us.ports.ubuntu.com/ubuntu-ports/ bionic main restricted >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 && \
    echo deb http://ppa.quickbuild.io/raptor-engineering-public/chromium/ubuntu bionic main >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.quickbuild.pearsoncomputing.net --recv-keys F0A175FC && \
    apt update
RUN apt install -y libavcodec57 libavformat57 libavutil55 libc6 libevent-2.1-6 libfontconfig1 libharfbuzz0b libjpeg8 libopenjp2-7 libre2-4 libva2 libvpx5 libwebpmux3 chromium-sandbox chromium
RUN ln -s /usr/bin/chromium /usr/bin/chromium-browser
EOF

sed -i 's/TAG := $(shell date +v%Y%m%d)-$(GIT_VERSION)/TAG ?= '"${RELEASE}"' /g' Makefile
sed -i 's/FROM node:12.22.8-alpine/FROM ppc64le\/node:12-stretch/g' Dockerfile
sed -i '12,20d' Dockerfile
sed -i "/# Installs latest Chromium package and configures environment for testing/r install-chromium.txt" Dockerfile
sed -i 's/npm test/#npm test/g' Dockerfile

sudo make build IMG=quay.io/ibm/${IMAGE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
