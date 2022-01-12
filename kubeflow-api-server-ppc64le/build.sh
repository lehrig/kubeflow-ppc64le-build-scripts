#!/bin/sh

cat >> Dockerfile.api <<'EOF'
# 1. Build api server application
# Use golang:1.13.1-stretch to keep GLIBC at 2.24 https://github.com/gotify/server/issues/225
FROM golang:1.13.1-stretch as builder
RUN apt-get update && apt-get install -y cmake clang musl-dev openssl
WORKDIR /go/src/github.com/kubeflow/pipelines
COPY . .
RUN go mod vendor
RUN GO111MODULE=on go build -o /bin/apiserver backend/src/apiserver/*.go

# 2. Compile preloaded pipeline samples
#FROM python:3.7 as compiler
FROM docker.io/mgiessing/osuosl-ubuntu-ppc64le:18.04 as compiler
RUN apt-get update -y && apt-get install --no-install-recommends -y -q default-jdk wget jq gcc unzip -y
RUN /bin/bash -c "source activate py37 && conda install -y -c conda-forge gmock gxx_linux-ppc64le=9.3.0 numpy=1.19.2 \
                && pip install opt-einsum==3.3.0 grpcio==1.32.0 \
                && conda install -y boost snappy brotli gflags libthrift gtest rapidjson utf8proc fastavro dill future google-crc32c pyyaml docopt scipy pandas flatbuffers=1.12.0 pyzmq scikit-learn h5py=2.10.0"
RUN wget https://ibm.box.com/shared/static/5c94rlqx82m25dllr35y8zm6pezld5ff.whl -O pyarrow-2.0.0-cp37-cp37m-linux_ppc64le.whl \
    && wget https://ibm.box.com/shared/static/6veoqg1h0kbtdnx8y3i8r4ochrv8w680.zip -O tfx-components-0.27.0.zip && unzip tfx-components-0.27.0.zip \
    && wget https://ibm.box.com/shared/static/kck489upyqsltkuv7ec576cag6651688.whl -O tensorflow-2.4.1-cp37-cp37m-linux_ppc64le.whl \
    && /bin/bash -c "source activate py37 && pip install pyarrow-2.0.0-cp37-cp37m-linux_ppc64le.whl \
                    && pip install apache-beam[gcp]==2.27.0 \
                    && pip install tensorboard==2.4.1 tensorflow-2.4.1-cp37-cp37m-linux_ppc64le.whl \
                    && pip install tfx-components-0.27.0/* \
                    && pip install tfx==0.27.0 --use-deprecated=legacy-resolver"
# Downloading Argo CLI so that the samples are validated
RUN apt-get update -y && apt-get install --no-install-recommends -y -q curl
ENV ARGO_VERSION v2.12.9
RUN curl -sLO https://github.com/argoproj/argo-workflows/releases/download/${ARGO_VERSION}/argo-linux-ppc64le.gz && \
  gunzip argo-linux-ppc64le.gz && \
  chmod +x argo-linux-ppc64le && \
  mv ./argo-linux-ppc64le /usr/local/bin/argo
WORKDIR /go/src/github.com/kubeflow/pipelines
COPY sdk sdk
WORKDIR /go/src/github.com/kubeflow/pipelines/sdk/python
RUN /bin/bash -c "source activate py37 && python3 setup.py install"
WORKDIR /
COPY ./samples /samples
COPY backend/src/apiserver/config/sample_config.json /samples/
# Compiling the preloaded samples.
# The default image is replaced with the GCR-hosted python image.
RUN set -e; \
    < /samples/sample_config.json jq .[].file --raw-output | while read pipeline_yaml; do \
        pipeline_py="${pipeline_yaml%.yaml}"; \
        mv "$pipeline_py" "${pipeline_py}.tmp"; \
	echo 'import kfp; kfp.components.default_base_image_or_builder="gcr.io/google-appengine/python:2020-03-31-141326"' | cat - "${pipeline_py}.tmp" > "$pipeline_py"; \
	/bin/bash -c "source activate py37 && dsl-compile --py \"$pipeline_py\" --output \"$pipeline_yaml\" || python3 \"$pipeline_py\""; \
    done

# 3. Start api web server
FROM ppc64le/debian:stretch
ARG COMMIT_SHA=unknown
ENV COMMIT_SHA=${COMMIT_SHA}
ARG TAG_NAME=unknown
ENV TAG_NAME=${TAG_NAME}
WORKDIR /bin
COPY third_party/license.txt /bin/license.txt
COPY backend/src/apiserver/config/ /config
COPY --from=builder /bin/apiserver /bin/apiserver
COPY --from=compiler /samples/ /samples/
RUN chmod +x /bin/apiserver
# Adding CA certificate so API server can download pipeline through URL and wget is used for liveness/readiness probe command
RUN apt-get update && apt-get install -y ca-certificates wget
# Pin sample doc links to the commit that built the backend image
RUN sed -E "s#/(blob|tree)/master/#/\1/${COMMIT_SHA}/#g" -i /config/sample_config.json && \
    sed -E "s/%252Fmaster/%252F${COMMIT_SHA}/#g" -i /config/sample_config.json
# Expose apiserver port
EXPOSE 8888
# Start the apiserver
CMD /bin/apiserver --config=/config --sampleconfig=/config/sample_config.json -logtostderr=true

EOF

sed -i 's/len(refKey.ID) > 0/len(refKey.ID) > 0 \&\& refKey.ID != "kubeflow-user-example-com"/g' backend/src/apiserver/server/experiment_server.go

sudo docker build -t quay.io/ibm/${IMAGE}:${RELEASE} -f Dockerfile.api .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
