#!/bin/sh

# Fixes for Error 139
sed -i 's/set -e//g' pkg/apis/manager/v1beta1/build.sh
sed -i 's/set -e//g' pkg/apis/manager/health/build.sh
echo 'echo "This is an Error 139 fix"' >> pkg/apis/manager/health/build.sh

sed -i 's/znly\/protoc/docker.io\/mgiessing\/protoc/g' pkg/apis/manager/v1beta1/build.sh
sed -i 's/znly\/protoc/docker.io\/mgiessing\/protoc/g' pkg/apis/manager/health/build.sh

sed -i 's/FROM pseudomuto\/protoc-gen-doc/FROM docker.io\/mgiessing\/protoc-gen-doc:1.5.7/g' pkg/apis/manager/v1beta1/gen-doc/Dockerfile
sed -i 's/node:12/ppc64le\/node:12/g' cmd/new-ui/v1beta1/Dockerfile

sed -i '/Building Katib cert generator image/,$d' scripts/v1beta1/build.sh

sudo apt-get update -y && sudo apt-get install openjdk-11-jdk -y
sudo env "PATH=$PATH" env "GOROOT=$GOROOT" env "GOPATH=$GOPATH" make build REGISTRY=quay.io/ibm TAG=${RELEASE} CPU_ARCH=ppc64le

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker tag quay.io/ibm/katib-controller:${RELEASE} quay.io/ibm/katib-controller-ppc64le:${RELEASE}
sudo docker tag quay.io/ibm/katib-db-manager:${RELEASE} quay.io/ibm/katib-db-manager-ppc64le:${RELEASE}
sudo docker tag quay.io/ibm/katib-ui:${RELEASE} quay.io/ibm/katib-ui-ppc64le:${RELEASE}

sudo docker push quay.io/ibm/katib-controller-ppc64le:${RELEASE}
sudo docker push quay.io/ibm/katib-db-manager-ppc64le:${RELEASE}
sudo docker push quay.io/ibm/katib-ui-ppc64le:${RELEASE}
