# Upgrade acs kubernetes cluster

Upgrade the ACS cluster by running the given script

## Disclaimer

**This is performed at own risk.**

Not yet tested on v 1.10.X and above.


## Prerequisites

The master must be able to log in to the nodes.
Log on to the master and generate an SSH key with an empty passphrase, if necessary:
```
ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ""

```
Add the masters public key to each of the nodes.

In azure portal do so by adding the public key to the "Reset password" section of each node.
Alternatively, use the Azure CLI:
```
az vm user update -u azureuser --ssh-key-value "<public key>" -n <node> -g <resource group>
```

## What it does


The script is intended to be executed on a running cluster.
It will drain a node, upgrade and uncordon it before moving on to the next node.

If you have few resources available in the cluster you can add on a new node so that
you are in the current state + 1 node, and then do the upgrade. In this way you will have the same resources available during upgrade as current.

After successful upgrade the +1 node can be drained and deleted.

## Execute

To upgrade the cluster run this script on the master machine

Give the current version and the new version of Kubernetes cluster.

```
curl https://raw.githubusercontent.com/evry-toolbox/acs-k8s-upgrade/master/upgrade.sh | sudo bash -s -- 1.7.7 1.8.4
```
