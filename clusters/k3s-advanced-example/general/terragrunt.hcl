locals {
  prox_creds = yamldecode(sops_decrypt_file(find_in_parent_folders("prox_creds.enc.yaml")))
  ssh_creds = yamldecode(sops_decrypt_file(find_in_parent_folders("ssh_creds.enc.yaml")))
  cluster_secrets = yamldecode(sops_decrypt_file(find_in_parent_folders("cluster_secrets.enc.yaml")))
  cluster_configs = yamldecode(file(find_in_parent_folders("cluster_configs.yaml")))
}

terraform {
    source = "../../../modules/k3s-split/agent"
}

include {
    path = find_in_parent_folders()
}

dependency "controlplane" {
  config_path = "../controlplane"
}

inputs = {
  cluster_name = local.cluster_configs.cluster_name
  cluster_secret = local.cluster_secrets.cluster_secret

  agent_name = "general"

  registration_host = dependency.controlplane.outputs.registration_host

  # Load Prox creds from encrypted secret
  prox_url = local.prox_creds.prox_url
  prox_api_id = local.prox_creds.prox_api_id
  prox_api_token = local.prox_creds.prox_api_token
  prox_nodes = local.prox_creds.prox_nodes

  agent_count = 1

  # Agent Node Metadata
  agent_memory = "8192"
  agent_cores = "3"
  agent_disk_size = "32G"

  agent_config = <<EOT
node-label:
  - "group=general"
EOT

  clone_template = "ubuntu-ci-template"
  qemu_agent = 1

  ssh_user = local.ssh_creds.ssh_user
  ssh_password = local.ssh_creds.ssh_password
  ssh_key_public = local.ssh_creds.ssh_key_public
  ssh_key_private = local.ssh_creds.ssh_key_private

  dns_servers = local.cluster_configs.dns_servers

  # If utilizing VLANs
  vlan_tag = 2
}
