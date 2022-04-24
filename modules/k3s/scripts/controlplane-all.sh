#!/bin/bash

echo "Installing add'l server node.."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" K3S_NODE_NAME="$1" K3S_TOKEN="$2" K3S_URL="https://$3:6443" sh -s - --no-deploy servicelb,traefik