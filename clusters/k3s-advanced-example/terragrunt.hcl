locals {
  prox_creds = yamldecode(sops_decrypt_file(find_in_parent_folders("prox_creds.enc.yaml")))
  ssh_creds = yamldecode(sops_decrypt_file(find_in_parent_folders("ssh_creds.enc.yaml")))
  cluster_secrets = yamldecode(sops_decrypt_file("cluster_secrets.enc.yaml"))
}

terraform {
    source = "../../modules/k3s"
}

include {
    path = find_in_parent_folders()
}

inputs = {
  cluster_name = "k3s-example"

  cluster_secret = local.cluster_secrets.cluster_secret

  # Load Prox creds from encrypted secret
  prox_url = local.prox_creds.prox_url
  prox_api_id = local.prox_creds.prox_api_id
  prox_api_token = local.prox_creds.prox_api_token
  prox_nodes = local.prox_creds.prox_nodes

  controlplane_count = 3
  agent_count = 3

  # Controlplane Node Metadata
  cp_memory = "8192"
  cp_cores = "3"
  cp_disk_size = "32G"

  # Agent Node Metadata
  agent_memory = "8192"
  agent_cores = "3"
  agent_disk_size = "32G"

  gateway = "192.168.1.1"

  clone_template = "ubuntu-ci-template"
  qemu_agent = 1

  ssh_user = local.ssh_creds.ssh_user
  ssh_password = local.ssh_creds.ssh_password
  ssh_key_public = local.ssh_creds.ssh_key_public
  ssh_key_private = local.ssh_creds.ssh_key_private

  dns_servers = "8.8.8.8"

  # If utilizing VLANs
  vlan_tag = 2
}
