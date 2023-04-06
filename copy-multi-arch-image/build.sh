#!/bin/sh

sudo docker run quay.io/skopeo/stable:latest copy --dest-username $quay_u --dest-password $quay_p --multi-arch all docker://$SOURCE_IMAGE docker://$TARGET_IMAGE
