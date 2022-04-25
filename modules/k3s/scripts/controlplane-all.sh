#!/bin/bash

RUN_INDEX=$1
SLEEP_TIME=$(( $RUN_INDEX * 10 ))
echo "Sleeping for $SLEEP_TIME.."
sleep $SLEEP_TIME

echo "Installing add'l server node.."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" K3S_NODE_NAME="$2" K3S_TOKEN="$3" K3S_URL="https://$4:6443" sh -s - --no-deploy servicelb,traefik