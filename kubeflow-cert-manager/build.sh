#!/bin/sh

sudo apt-get update && sudo apt-get install python2.7 -y
sudo ln -s /usr/bin/python2.7 /usr/bin/python2
conda install bazel==0.24.1 -y

# Change image architecture to Power
sed -i 's/amd64/ppc64le/g' Makefile
sed -i 's/linux_amd64/ppc64le/g' hack/ci/lib/build_images.sh
sed -i '106,129d' WORKSPACE

sudo chmod 777 /var/run/docker.sock

make images

docker images

docker tag quay.io/jetstack/cert-manager-cainjector-ppc64le:canary quay.io/ibm/cert-manager-cainjector-ppc64le:${RELEASE}
docker tag quay.io/jetstack/cert-manager-controller-ppc64le:canary quay.io/ibm/cert-manager-controller-ppc64le:${RELEASE}
docker tag quay.io/jetstack/cert-manager-webhook-ppc64le:canary quay.io/ibm/cert-manager-webhook-ppc64le:${RELEASE}

set +x
echo $quay_p | docker login --username $quay_u --password-stdin https://quay.io
set -x

docker push quay.io/ibm/cert-manager-cainjector-ppc64le:${RELEASE}
docker push quay.io/ibm/cert-manager-controller-ppc64le:${RELEASE}
docker push quay.io/ibm/cert-manager-webhook-ppc64le:${RELEASE}

