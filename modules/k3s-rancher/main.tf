terraform {
  required_version = ">= 0.14"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.prox_url
  pm_api_token_id     = var.prox_api_id
  pm_api_token_secret = var.prox_api_token
}

resource "random_shuffle" "prox_nodes" {
  input        = var.prox_nodes
  result_count = var.result_count

  keepers = {
    cluster_name = "${var.cluster_name}"
  }
}

resource "proxmox_vm_qemu" "controlplane_all" {
  count       = var.controlplane_count
  name        = join("", [random_shuffle.prox_nodes.keepers.cluster_name, "-cp-", count.index + 1])
  target_node = random_shuffle.prox_nodes.result[count.index]
  ipconfig0   = "ip=dhcp"

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = true
    tag      = var.vlan_tag
  }

  agent  = var.qemu_agent
  clone  = var.clone_template
  bios   = var.bios
  scsihw = var.scsihw

  memory     = var.cp_memory
  cores      = var.cp_cores
  os_type    = var.os_type
  nameserver = var.dns_servers
  sshkeys    = var.ssh_key_public
  ciuser     = var.ssh_user
  cipassword = var.ssh_password

  disk {
    type    = var.disk_type
    storage = var.storage_pool
    size    = var.cp_disk_size
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.ssh_key_private
    host        = self.ssh_host
  }

  provisioner "file" {
    source      = "scripts/controlplane-all.sh"
    destination = "/tmp/controlplane-all.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/controlplane-all.sh",
      "sudo /tmp/controlplane-all.sh \"${var.rancher_token}\" \"${var.rancher_checksum}\" \"${var.rancher_url}\""
    ]
  }
}

resource "proxmox_vm_qemu" "agents" {
  count       = var.agent_count
  name        = join("", [random_shuffle.prox_nodes.keepers.cluster_name, "-agent-", count.index + 1])
  target_node = random_shuffle.prox_nodes.result[var.controlplane_count + count.index]
  ipconfig0   = "ip=dhcp"
  agent       = var.qemu_agent
  clone       = var.clone_template
  bios        = var.bios
  scsihw      = var.scsihw

  memory     = var.agent_memory
  cores      = var.agent_cores
  os_type    = var.os_type
  nameserver = var.dns_servers
  sshkeys    = var.ssh_key_public
  ciuser     = var.ssh_user
  cipassword = var.ssh_password

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = true
    tag      = var.vlan_tag
  }

  disk {
    type    = var.disk_type
    storage = var.storage_pool
    size    = var.agent_disk_size
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.ssh_key_private
    host        = self.ssh_host
  }

  provisioner "file" {
    source      = "scripts/agent.sh"
    destination = "/tmp/agent.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/agent.sh",
      "sudo /tmp/agent.sh \"${var.rancher_token}\" \"${var.rancher_checksum}\" \"${var.rancher_url}\""
    ]
  }

  depends_on = [
    proxmox_vm_qemu.controlplane_all,
  ]
}