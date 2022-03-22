#!/bin/sh

sed -i 's/amd64/ppc64le/g' agent.Dockerfile

sudo env "PATH=$PATH" make docker-build-agent KO_DOCKER_REPO=quay.io/ibm AGENT_IMG=${IMAGE}:${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
