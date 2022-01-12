#!/bin/sh

##Build Argo v2.12.9:

#PreReq 1: docker (v19.03 as --progress wasn't supported by older versions)
sudo apt-get remove docker docker-engine docker-ce docker.io -y
sudo apt-get update && sudo apt-get install containerd python2.7 -y
sudo ln -s /usr/bin/python2.7 /usr/bin/python2

wget https://oplab9.parqtec.unicamp.br/pub/ppc64el/docker/version-19.03.8/ubuntu-bionic/docker-ce_19.03.8~3-0~ubuntu-bionic_ppc64el.deb
wget https://oplab9.parqtec.unicamp.br/pub/ppc64el/docker/version-19.03.8/ubuntu-bionic/docker-ce-cli_19.03.8~3-0~ubuntu-bionic_ppc64el.deb
sudo dpkg -i docker-ce-cli_19.03.8~3-0~ubuntu-bionic_ppc64el.deb docker-ce_19.03.8~3-0~ubuntu-bionic_ppc64el.deb

#PreReqs: make, cmake, autoconf, libtools, kubectl nodejs>=14.8.0 & yarn 1.22.10 were working here
conda install make cmake autoconf libtool nodejs yarn -y
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/ppc64le/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Change image architecture to Power
sed -i "s/OUTPUT_IMAGE_ARCH ?= amd64/OUTPUT_IMAGE_ARCH ?= ppc64le/g" Makefile
sed -i '/aarch64/a \    elif [ "${IMAGE_OS}" = "linux" -a "${IMAGE_ARCH}" = "ppc64le" ]; then \ \' Dockerfile.dev
sed -i '/ppc64le/a \        wget -O docker.tgz https://download.docker.com/linux/static/stable/ppc64le/docker-18.06.3-ce.tgz; \ \' Dockerfile.dev

sudo env "PATH=$PATH" make argo-server.key
sudo env "PATH=$PATH" make images

sudo docker tag argoproj/workflow-controller:latest quay.io/ibm/kubeflow-workflow-controller-ppc64le:${RELEASE}
sudo docker tag argoproj/argoexec:latest quay.io/ibm/kubeflow-argoexec-ppc64le:${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/kubeflow-workflow-controller-ppc64le:${RELEASE}
sudo docker push quay.io/ibm/kubeflow-argoexec-ppc64le:${RELEASE}
