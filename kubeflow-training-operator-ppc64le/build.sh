#!/bin/sh

# Follow https://github.com/kubeflow/tf-operator/blob/cd2fc1ff397b1f349f68524f4abd5013a32e3033/developer_guide.md

export GIT_TRAINING=$(pwd)

sudo env "PATH=$PATH" mkdir -p $(go env GOPATH)/src/github.com/kubeflow
sudo env "PATH=$PATH" ln -sf ${GIT_TRAINING} $(go env GOPATH)/src/github.com/kubeflow/tf-operator
sudo env "PATH=$PATH" GO111MODULE="on" go mod vendor
sudo env "PATH=$PATH" go install github.com/kubeflow/tf-operator/cmd/tf-operator.v1

sed -i 's/GOARCH=amd64/GOARCH=ppc64le/g' build/images/tf_operator/Dockerfile
sed -i 's/from kubeflow.testing import util/#from kubeflow.testing import util/g' py/kubeflow/tf_operator/util.py
sed -i 's/should_push=True/should_push=False/g' py/kubeflow/tf_operator/release.py

cd py
pip install --upgrade --quiet --no-cache-dir filelock pyyaml google-api-python-client google-cloud-speech google-cloud-storage jinja2 kubernetes
sudo env "PATH=$PATH" env "GOPATH=$GOPATH" python -m kubeflow.tf_operator.release local

sudo docker tag gcr.io/kubeflow-ci/tf_operator:latest quay.io/ibm/${IMAGE}:${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
