#!/usr/bin/env bash

CURRENT_VERSION=$1
TARGET_VERSION=$2
echo "CURRENT_VERSION: $CURRENT_VERSION"
echo "TARGET_VERSION: $TARGET_VERSION"

sed -i -e "s@hyperkube-amd64:v$CURRENT_VERSION@hyperkube-amd64:v$TARGET_VERSION@g" /etc/default/kubelet && \

# restarting kubelet
systemctl daemon-reload && \
systemctl restart kubelet