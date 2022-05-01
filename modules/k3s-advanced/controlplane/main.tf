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

resource "proxmox_vm_qemu" "controlplane_first" {
  name        = "${random_shuffle.prox_nodes.keepers.cluster_name}-cp-1"
  target_node = random_shuffle.prox_nodes.result[0]
  ipconfig0   = "ip=dhcp"
  agent       = var.qemu_agent
  clone       = var.clone_template

  network {
    model = "virtio"
    bridge = "vmbr0"
    firewall = true
    tag = var.vlan_tag
  }

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
    content      = var.cp_config
    destination = "/tmp/config.yaml"
  }

  provisioner "file" {
    source      = "scripts/controlplane-first.sh"
    destination = "/tmp/controlplane.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/rancher/k3s",
      "sudo mv /tmp/config.yaml /etc/rancher/k3s/config.yaml",
      "sudo chmod +x /tmp/controlplane.sh",
      "sudo /tmp/controlplane.sh \"${var.controlplane_count}\" \"${self.name}\" \"${var.cluster_secret}\""
    ]
  }
}

resource "proxmox_vm_qemu" "controlplane_all" {
  count       = var.controlplane_count - 1
  name        = join("", [random_shuffle.prox_nodes.keepers.cluster_name, "-cp-", count.index + 2])
  target_node = random_shuffle.prox_nodes.result[count.index+1]
  ipconfig0   = "ip=dhcp"

  network {
    model = "virtio"
    bridge = "vmbr0"
    firewall = true
    tag = var.vlan_tag
  }

  agent       = var.qemu_agent
  clone       = var.clone_template

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
    content      = var.cp_config
    destination = "/tmp/config.yaml"
  }

  provisioner "file" {
    source      = "scripts/controlplane-all.sh"
    destination = "/tmp/controlplane.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/rancher/k3s",
      "sudo mv /tmp/config.yaml /etc/rancher/k3s/config.yaml",
      "sudo chmod +x /tmp/controlplane.sh",
      "sudo /tmp/controlplane-all.sh \"${count.index}\" \"${self.name}\" \"${var.cluster_secret}\" \"${proxmox_vm_qemu.controlplane_first.ssh_host}\""
    ]
  }

  depends_on = [
    proxmox_vm_qemu.controlplane_first,
  ]
}