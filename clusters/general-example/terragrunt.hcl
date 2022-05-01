locals {
  prox_creds = yamldecode(sops_decrypt_file(find_in_parent_folders("prox_creds.enc.yaml")))
  ssh_creds = yamldecode(sops_decrypt_file(find_in_parent_folders("ssh_creds.enc.yaml")))
}

terraform {
    source = "../../modules/general"
}

include {
    path = find_in_parent_folders()
}

inputs = {
  cluster_name = "general-example"

  # Load Prox creds from encrypted secret
  prox_url = local.prox_creds.prox_url
  prox_api_id = local.prox_creds.prox_api_id
  prox_api_token = local.prox_creds.prox_api_token
  prox_nodes = local.prox_creds.prox_nodes

  node_count = 1

  # Node Metadata
  node_memory = "8192"
  node_cores = "3"
  node_disk_size = "32G"

  # Init script for node
  node_init_script = <<EOT
  #!/bin/bash

  # Put your init stuff here
  # apt update -y
  EOT

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
