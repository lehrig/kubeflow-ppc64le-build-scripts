#!/bin/sh

sudo apt-get update -y && sudo apt-get install skopeo -y

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

skopeo copy --multi-arch all docker://$SOURCE_IMAGE docker://$TARGET_IMAGE
