#!/bin/sh

# buildx not supported with Jenkins
# see: https://issues.jenkins.io/browse/JENKINS-61372?page=com.atlassian.streams.streams-jira-plugin%3Aactivity-stream-issue-tab
sed -i "s/buildx build/build/g" Makefile

sudo env "PATH=$PATH" make argo-server.key
sudo env "PATH=$PATH" make images

sudo docker tag argoproj/workflow-controller:latest quay.io/ibm/kubeflow-workflow-controller-ppc64le:${RELEASE}
sudo docker tag argoproj/argoexec:latest quay.io/ibm/kubeflow-argoexec-ppc64le:${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/kubeflow-workflow-controller-ppc64le:${RELEASE}
sudo docker push quay.io/ibm/kubeflow-argoexec-ppc64le:${RELEASE}
