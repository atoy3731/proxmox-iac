#!/bin/bash

echo "Installing agent node.."
curl -fL https://rancher.atoy.lol/system-agent-install.sh | sudo  sh -s - --server https://rancher.atoy.lol --label 'cattle.io/os=linux' --token "$1" --ca-checksum "$2" --worker