variable "cluster_name" {
  description = "Name of cluster"
  type = string
  default = "foobar"
}

variable "cp_memory" {
  description = "Memory for each node"
  type        = string
  default     = "8192"
}

variable "ssh_password" {
  description = "SSH Password"
  type = string
  default = null
}

variable "cp_cores" {
  description = "Cores for each node"
  type        = number
  default     = 2
}

variable "register_ip_addr" {
  description = "Static IP for configuring k8s cluster"
  type = string
  default = "192.168.1.1"
}

variable "gateway" {
  description = "Gateway IP"
  type = string
  default = "192.168.1.1"
}

variable "controlplane_count" {
  description = "Number of controlplane nodes"
  type = number
  default = 1
}

variable "worker_count" {
  description = "Number of worker nodes"
  type = number
  default = 0
}

variable "prox_nodes" {
  description = "Array of ProxMox node names"
  type = list(string)
  default = ["prox1", "prox2", "prox3"]
}

variable "clone_template" {
  description = "Source template to clone"
  type        = string
  default     = "ci-ubuntu-template"
}

variable "qemu_agent" {
  description = "Enable qemu guest agent"
  type        = number
  default     = 0
}

variable "ssh_user" {
  description = "Username for ssh"
  type = string
  default = "user"
}

variable "ssh_key" {
  description = "SSH private key"
  type = string
  default = "~/.ssh/id_ed25519"
}

variable "ssh_key_public" {
  description = "SSH public key"
  type = string
  default = <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5gDqGux/p7JR/I/mBE/LYoJc8RBdSikmyVj7OTqBMW andrewsgreene89@gmail.com
EOF
}

variable "os_type" {
  description = "OS Type, cloud-init"
  type = string
  default = "cloud-init"
}

variable "dns_servers" {
  description = "DNS server address"
  type = string
  default = "192.168.1.198 192.168.1.199"
}

variable "disk_type" {
  type = string
  default = "scsi"
}

variable "storage_pool" {
  type = string
  default = "local-lvm"
}

variable "cp_disk_size" {
  type = string
  default = "75G"
}

variable "prox_url" {
  type = string
  default = "https://prox2.atoy.lol:8006/api2/json"
}

variable "prox_api_id" {
  type = string
}

variable "prox_api_token" {
  type = string
}
