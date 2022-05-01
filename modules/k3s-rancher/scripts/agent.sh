#!/bin/bash

echo "Installing agent node.."
curl -fL https://$3/system-agent-install.sh | sudo  sh -s - --server https://$3 --label 'cattle.io/os=linux' --token "$1" --ca-checksum "$2" --worker