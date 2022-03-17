#!/bin/sh

## Begin: Install Java
export JAVA_HOME=$(pwd)/java
wget http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.7.5/linux/ppc64le/ibm-java-sdk-8.0-7.5-ppc64le-archive.bin
chmod +x ibm-java-sdk-8.0-7.5-ppc64le-archive.bin
cat >> installer.properties <<EOF
INSTALLER_UI=silent
USER_INSTALL_DIR=$JAVA_HOME
LICENSE_ACCEPTED=TRUE
EOF

./ibm-java-sdk-8.0-7.5-ppc64le-archive.bin -r ./installer.properties

export PATH=$JAVA_HOME/bin:$PATH
rm -f ./installer.properties
rm -f ./ibm-java-sdk-8.0-7.5-ppc64le-archive.bin
## Finshed: Install Java

sed -i 's/set -e//g' pkg/apis/manager/v1beta1/build.sh
sed -i 's/znly\/protoc/docker.io\/mgiessing\/protoc/g' pkg/apis/manager/v1beta1/build.sh
sed -i 's/FROM pseudomuto\/protoc-gen-doc/FROM docker.io\/mgiessing\/protoc-gen-doc:1.5.7/g' pkg/apis/manager/v1beta1/gen-doc/Dockerfile
sed -i 's/node:12/ppc64le\/node:12/g' cmd/new-ui/v1beta1/Dockerfile
sed -i '/Building Katib cert generator image/,$d' scripts/v1beta1/build.sh

sudo env "PATH=$PATH" env "GOROOT=$GOROOT" env "GOPATH=$GOPATH" make build REGISTRY=quay.io/ibm TAG=${RELEASE} CPU_ARCH=ppc64le

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker tag ${REGISTRY}/katib-controller:${RELEASE} ${REGISTRY}/katib-controller-ppc64le:${RELEASE}
sudo docker tag ${REGISTRY}/katib-db-manager:${RELEASE} ${REGISTRY}/katib-db-manager-ppc64le:${RELEASE}
sudo docker tag ${REGISTRY}/katib-ui:${RELEASE} ${REGISTRY}/katib-ui-ppc64le:${RELEASE}

sudo docker push ${REGISTRY}/katib-controller-ppc64le:${RELEASE}
sudo docker push ${REGISTRY}/katib-db-manager-ppc64le:${RELEASE}
sudo docker push ${REGISTRY}/katib-ui-ppc64le:${RELEASE}
