#!/bin/bash

echo "Copying files.."
mkdir -p /var/lib/rancher/k3s/agent/images/
wget https://github.com/k3s-io/k3s/releases/download/v1.22.8%2Bk3s1/k3s-airgap-images-amd64.tar.gz -P /var/lib/rancher/k3s/agent/images/

echo "Downloading k3s binary.."
wget https://github.com/k3s-io/k3s/releases/download/v1.22.8%2Bk3s1/k3s > /usr/local/bin/
chmod +x /usr/local/bin/k3s

echo "Downloading k3s installer.."
curl -sfL https://get.k3s.io > /opt/install.sh
chmod +x /opt/install.sh


cat <<EOT > /opt/start.sh
#!/bin/bash
INSTALL_K3S_SKIP_DOWNLOAD=true /opt/install.sh
EOT

chmod +x /opt/start.sh

