#!/bin/bash

echo "Installing QEMU Guest Agent and curl.."
apt update -y
apt install -y qemu-guest-agent curl

echo "Downloading k3s binary.."
curl -sfL https://get.k3s.io > /tmp/k3s.sh
chmod +x /tmp/k3s.sh