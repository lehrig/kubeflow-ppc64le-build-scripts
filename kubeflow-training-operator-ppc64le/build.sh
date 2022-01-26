#!/bin/sh

# Follow https://github.com/kubeflow/training-operator/blob/master/docs/development/developer_guide.md
export GIT_TRAINING=$(pwd)
sudo env "PATH=$PATH" mkdir -p $(go env GOPATH)/src/github.com/kubeflow
sudo env "PATH=$PATH" ln -sf ${GIT_TRAINING} $(go env GOPATH)/src/github.com/kubeflow/training-operator
sudo env "PATH=$PATH" GO111MODULE="on" go mod vendor
sudo env "PATH=$PATH" go install github.com/kubeflow/tf-operator/cmd/training-operator.v1

# ppc64le fixes
sed -i 's/GOARCH=amd64/GOARCH=ppc64le/g' build/images/training-operator/Dockerfile

sudo docker build -t quay.io/ibm/${IMAGE}:${RELEASE} -f build/images/training-operator/Dockerfile .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
