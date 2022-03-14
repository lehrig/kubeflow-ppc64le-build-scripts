#!/bin/sh

sed -i 's/znly\/protoc/mgiessing\/protoc/g' pkg/apis/manager/v1beta1/build.sh
sed -i 's/FROM pseudomuto\/protoc-gen-doc/FROM mgiessing\/protoc-gen-doc/g' pkg/apis/manager/v1beta1/gen-doc/Dockerfile
sed -i 's/node:12/ppc64le\/node:12/g' cmd/new-ui/v1beta1/Dockerfile
sed -i '/Building Katib cert generator image/,$d' scripts/v1beta1/build.sh

sudo env "PATH=$PATH" make build REGISTRY=quay.io/ibm TAG=${RELEASE} CPU_ARCH=ppc64le

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker tag ${REGISTRY}/katib-controller:${RELEASE} ${REGISTRY}/katib-controller-ppc64le:${RELEASE}
sudo docker tag ${REGISTRY}/katib-db-manager:${RELEASE} ${REGISTRY}/katib-db-manager-ppc64le:${RELEASE}
sudo docker tag ${REGISTRY}/katib-ui:${RELEASE} ${REGISTRY}/katib-ui-ppc64le:${RELEASE}

sudo docker push ${REGISTRY}/katib-controller-ppc64le:${RELEASE}
sudo docker push ${REGISTRY}/katib-db-manager-ppc64le:${RELEASE}
sudo docker push ${REGISTRY}/katib-ui-ppc64le:${RELEASE}
