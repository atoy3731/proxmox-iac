terraform {
  required_version = ">= 0.14"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.prox_url
  pm_api_token_id = var.prox_api_id
  pm_api_token_secret = var.prox_api_token
}

resource "random_shuffle" "prox_nodes" {
  input        = var.prox_nodes
  result_count = 1
}

resource "proxmox_vm_qemu" "controlplane" {
  count = var.controlplane_count
  name = "${var.cluster_name}-cp-1"
  target_node = random_shuffle.prox_nodes.result[0]
  # ipconfig0 = count.index == 0 ? "ip=${var.register_ip_addr}/24,gw=${var.gateway}" : null
  agent = var.qemu_agent
  clone = var.clone_template

  memory = var.cp_memory
  cores = var.cp_cores
  os_type   = var.os_type
  # nameserver = var.dns_servers
  # sshkeys = var.ssh_key_public
  ciuser = var.ssh_user
  cipassword = var.ssh_password

  # disk {
  #   type = var.disk_type
  #   storage = var.storage_pool
  #   size = var.cp_disk_size
  # }

  provisioner "file" {
    source = "scripts/common.sh"
    destination = "/tmp/common.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/common.sh",
      "/tmp/common.sh"
    ]
  }

  # provisioner "remote-exec" {
  #   inline = [
      
  #     "chmod +x /tmp/k3s.sh",
  #     "/tmp/k3s.sh -n mgmt2 -t ${random_string.random.result} -s https://192.168.1.210:6443 -d",
  #   ]
  # }

  # provisioner "file" {
  #   source = "local/path/to/script.sh"
  #   destination = "/tmp/script.sh"

  #   connection {
  #     type     = "ssh"
  #     user     = var.ssh_user
  #     private_key = "${file(var.ssh_key)}"
  #     host = self.ssh_host
  #   }
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "command 1",
  #     "command 2",
  #   ]
  #   connection {
  #     type     = "ssh"
  #     user     = var.ssh_user
  #     private_key = "${file(var.ssh_key)}"
  #     host = self.ssh_host
  #   }
  # }
}
