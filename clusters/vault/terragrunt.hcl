locals {
  prox_creds = yamldecode(sops_decrypt_file(find_in_parent_folders("prox_creds.enc.yaml")))
  ssh_creds = yamldecode(sops_decrypt_file("ssh_creds.enc.yaml"))

}

terraform {
    source = "../../modules/k3s"
}

include {
    path = find_in_parent_folders()
}

inputs = {
  cluster_name = "vault"

  # Load Prox creds from encrypted secret
  prox_url = local.prox_creds.prox_url
  prox_api_id = local.prox_creds.prox_api_id
  prox_api_token = local.prox_creds.prox_api_token
  prox_nodes = local.prox_creds.prox_nodes

  # Node Metadata
  cp_memory = "8192"
  cp_cores = "3"
  cp_disk_size = "32G"

  register_ip_addr = "10.0.10.343"
  gateway = "10.0.10.1"

  controlplane_count = 1
  worker_count = 0

  clone_template = "ubuntu-ci-template"
  qemu_agent = 1

  ssh_user = local.ssh_creds.ssh_user
  ssh_password = local.ssh_creds.ssh_password
  ssh_key_public = local.ssh_creds.ssh_key_public

  dns_servers = "10.0.10.1"
}
