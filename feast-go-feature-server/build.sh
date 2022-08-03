#!/bin/sh

cat > feature_store.yaml <<'EOF'
project: feast_repo
registry: data/registry.db
provider: local
online_store:
  type: redis
  connection_string: ${REDIS_HOST:"my-redis-master.redis.svc:6379"},password=${REDIS_PASSWORD}
go_feature_serving: True
  feature_logging:
    enable: True
    flush_interval_secs: 300
    write_to_disk_interval_secs: 30
    emit_timeout_micro_secs: 10000
    queue_capacity: 10000
EOF

cat > Dockerfile <<EOF
FROM python:3.8
  
RUN mkdir ~/.pip && \\
    echo "[global]" >> ~/.pip/pip.conf && \\
    echo "extra-index-url = https://repo.fury.io/mgiessing" >> ~/.pip/pip.conf && \\
    pip install pip --upgrade && \\
    pip install --prefer-binary \\
      feast[redis,go]==${RELEASE} \\
    && \\
    mkdir -p /.cache && \\
    chgrp -R 0 /.cache && \\
    chmod -R g=u /.cache && \\
    mkdir -p /data && \\
    chgrp -R 0 /data && \\
    chmod -R g=u /data && \\
    chgrp -R 0 /usr/local/lib/python3.8 && \\
    chmod -R g=u /usr/local/lib/python3.8

COPY feature_store.yaml /feature_store.yaml
EOF

export TARGET=quay.io/ibm/${IMAGE}:v${RELEASE}
docker build -t ${TARGET} -f Dockerfile .

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push ${TARGET}
