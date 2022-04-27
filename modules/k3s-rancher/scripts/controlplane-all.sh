#!/bin/bash

RUN_INDEX=$1
SLEEP_TIME=$(( $RUN_INDEX * 10 ))
echo "Sleeping for $SLEEP_TIME.."
sleep $SLEEP_TIME

echo "Installing via Rancher.."
curl -fL https://rancher.atoy.lol/system-agent-install.sh | sudo  sh -s - --server https://rancher.atoy.lol --label 'cattle.io/os=linux' --token "$1" --ca-checksum "$2" --etcd --controlplane