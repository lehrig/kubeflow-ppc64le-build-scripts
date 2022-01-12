#!/bin/sh

#sed -i '/var enableLeaderElection bool/a var mgr manager' main.go
#sed -i '/var enableLeaderElection bool/a var err error' main.go

cat >> patch-main.txt <<'EOF'
mgr, err := ctrl.NewManager(ctrl.GetConfigOrDie(), ctrl.Options{
		Scheme:             scheme,
		MetricsBindAddress: metricsAddr,
		LeaderElection:     enableLeaderElection,
		Port:               9443,
		SyncPeriod:         &syncPeriod,
		Namespace:          namespace,
	})
EOF

sed -i '61,78d' main.go
sed -i "/syncPeriod := 2 \* time.Minute/r patch-main.txt" main.go

#sudo make build REGISTRY=quay.io/ibm IMAGE_NAME=${IMAGE} TAG=${RELEASE} ARCH=ppc64le

sudo docker build --network=host --pull --build-arg ARCH=ppc64le . -t quay.io/ibm/${IMAGE}:${RELEASE}

set +x
echo $quay_p | sudo docker login --username $quay_u --password-stdin https://quay.io
set -x

sudo docker push quay.io/ibm/${IMAGE}:${RELEASE}
