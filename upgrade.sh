#!/usr/bin/env bash

CURRENT_VERSION=$1
TARGET_VERSION=$2
echo "CURRENT_VERSION: $CURRENT_VERSION"
echo "TARGET_VERSION: $TARGET_VERSION"

if [ -z "$CURRENT_VERSION" ]; then
  echo "Error: Missing parameter for current version. Example: 'sudo bash upgrade.sh 1.7.7 1.7.8'"
  exit 0
fi
if [ -z "$TARGET_VERSION" ]; then
  echo "Error: Missing parameter for target version. Example: 'sudo bash upgrade.sh 1.7.7 1.7.8'"
  exit 0
fi

SCRIPT_URL="https://raw.githubusercontent.com/evry-toolbox/acs-k8s-upgrade/master/node_upgrade.sh"
SCRIPT_URL_MASTER="https://raw.githubusercontent.com/evry-toolbox/acs-k8s-upgrade/master/master_upgrade.sh"
SSH_KEY="id_rsa"

echo "Upgrading kubectl on master..." && \
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
chmod +x ./kubectl && \
mv ./kubectl /usr/local/bin/kubectl && \
echo "Upgrading kubelet and manifests..." && \

nodes=$(kubectl get no -L kubernetes.io/role -l kubernetes.io/role=agent --no-headers -o jsonpath="{.items[*].metadata.name}" | tr " " "\n")

for node in $nodes; do
    echo "Cordoning $node..." && kubectl cordon $node && \
    echo "Draining $node..." && kubectl drain $node --ignore-daemonsets && \
    ssh -n -l $(logname) -i /home/$(logname)/.ssh/$SSH_KEY -t -oStrictHostKeyChecking=no $node "echo 'Working on $node...' && curl -LOk $SCRIPT_URL && sudo bash node_upgrade.sh $CURRENT_VERSION $TARGET_VERSION" && \
    echo "Uncordoning $node..." && kubectl uncordon $node
done

echo "Updating master node"

grep -rl hyperkube-amd64:v$CURRENT_VERSION /etc/kubernetes | xargs sed -i "s@hyperkube-amd64:v$CURRENT_VERSION@hyperkube-amd64:v$TARGET_VERSION@g"
curl -LOk $SCRIPT_URL && sudo bash node_upgrade.sh $CURRENT_VERSION $TARGET_VERSION

echo "Upgrade complete!"