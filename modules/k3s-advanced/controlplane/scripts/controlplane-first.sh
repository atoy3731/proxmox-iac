#!/bin/bash

echo "Installing first server node.."
if [[ "$1" == "1" ]]; then
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" K3S_NODE_NAME="$2" K3S_TOKEN="$3" sh -s - --no-deploy servicelb,traefik
else
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" K3S_NODE_NAME="$2" K3S_TOKEN="$3" sh -s - --cluster-init --no-deploy servicelb,traefik
fi