#!/bin/sh

cat >> Dockerfile.metadata_envoy <<'EOF'
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM lehrig/envoy:v0.1.32.ppc64le
RUN apt-get update -y && \
  apt-get install --no-install-recommends -y -q gettext openssl
COPY third_party/metadata_envoy/envoy.yaml /etc/envoy.yaml
# Copy license files.
#RUN mkdir -p /third_party
COPY third_party/metadata_envoy/license.txt /third_party/license.txt
ENTRYPOINT ["/usr/local/bin/envoy", "-c"]
CMD ["/etc/envoy.yaml"]

EOF


sudo docker build -t quay.io/ibm/${IMAGE}:${RELEASE} -f Dockerfile.metadata_envoy .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
