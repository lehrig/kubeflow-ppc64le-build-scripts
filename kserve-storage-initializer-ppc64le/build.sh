#!/bin/sh

cat >> configure-gemfury.txt <<'EOF'
RUN mkdir ~/.pip && \
    echo "[global]" >> ~/.pip/pip.conf && \
    echo "extra-index-url = https://repo.fury.io/mgiessing" >> ~/.pip/pip.conf
EOF
sed -i "/FROM python/r configure-gemfury.txt" python/storage-initializer.Dockerfile

sudo env "PATH=$PATH" make docker-build-storageInitializer KO_DOCKER_REPO=quay.io/ibm STORAGE_INIT_IMG=${IMAGE}:${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
