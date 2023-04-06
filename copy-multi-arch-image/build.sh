#!/bin/sh

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker run quay.io/skopeo/stable:latest copy --multi-arch all docker://$SOURCE_IMAGE docker://$TARGET_IMAGE
