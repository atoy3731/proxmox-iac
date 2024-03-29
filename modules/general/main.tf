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
    cluster_name = var.cluster_name
  }
}

resource "proxmox_vm_qemu" "nodes" {
  count       = var.node_count
  name        = join("", [random_shuffle.prox_nodes.keepers.cluster_name, "-", count.index + 1])
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

  memory     = var.node_memory
  cores      = var.node_cores
  os_type    = var.os_type
  nameserver = var.dns_servers
  sshkeys    = var.ssh_key_public
  ciuser     = var.ssh_user
  cipassword = var.ssh_password

  disk {
    type    = var.disk_type
    storage = var.storage_pool
    size    = var.node_disk_size
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.ssh_key_private
    host        = self.ssh_host
  }

  provisioner "file" {
    content     = var.node_init_script
    destination = "/tmp/init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/init.sh",
      "sudo /tmp/init.sh"
    ]
  }
}