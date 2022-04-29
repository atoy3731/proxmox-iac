##########
# Common #
##########

variable "cluster_name" {
  description = "Name of cluster"
  type        = string
  default     = "foobar"
}

variable "rancher_token" {
  description = "Cluster secret for nodes joining k3s"
  type        = string
}

variable "rancher_checksum" {
  description = "Rancher checksum"
  type = string
}

variable "vlan_tag" {
  description = "Tag for VLAN (Optional)"
  type = number
  default = -1
}

variable "result_count" {
  description = "Count of results. Needs to be higher than the future expected full number of nodes."
  type = number
  default = 10
}

variable "gateway" {
  description = "Gateway IP"
  type        = string
  default     = "192.168.1.1"
}

variable "clone_template" {
  description = "Source template to clone in Proxmox. Needs cloud-init and to exist on each node with the same name."
  type        = string
  default     = "ci-ubuntu-template"
}

variable "qemu_agent" {
  description = "Enable qemu guest agent"
  type        = number
  default     = 0
}

variable "os_type" {
  description = "OS Type, cloud-init"
  type        = string
  default     = "cloud-init"
}

variable "dns_servers" {
  description = "DNS server address"
  type        = string
  default     = "192.168.1.198 192.168.1.199"
}

variable "disk_type" {
  description = "Disk type to use for volumes"
  type        = string
  default     = "scsi"
}

variable "storage_pool" {
  description = "Storage pool in Proxmox to use for volumes"
  type        = string
  default     = "local-lvm"
}

#######
# SSH #
#######

variable "ssh_user" {
  description = "Username for ssh to nodes"
  type        = string
  default     = "user"
}

variable "ssh_password" {
  description = "SSH Password (Optional)"
  type        = string
  default     = null
}

variable "ssh_key_private" {
  description = "SSH private key"
  type        = string
}

variable "ssh_key_public" {
  description = "SSH public key"
  type        = string
}

################
# ControlPlane #
################

variable "controlplane_count" {
  description = "Number of controlplane nodes"
  type        = number
  default     = 1
}

variable "cp_disk_size" {
  description = "Disk size of the controlplane nodes"
  type        = string
  default     = "75G"
}

variable "cp_cores" {
  description = "Cores for each controlplane node"
  type        = number
  default     = 2
}

variable "cp_memory" {
  description = "Memory for each controlplane node"
  type        = string
  default     = "8192"
}

##########
# Agents #
##########

variable "agent_count" {
  description = "Number of agent nodes"
  type        = number
  default     = 0
}

variable "agent_disk_size" {
  type    = string
  default = "10G"
}

variable "agent_cores" {
  description = "Cores for each agent node"
  type        = number
  default     = 2
}

variable "agent_memory" {
  description = "Memory for each agent node"
  type        = string
  default     = "8192"
}

###########
# ProxMox #
###########

variable "prox_url" {
  description = "URL for the Proxmox API"
  type        = string
  default     = "https://prox1.atoy.lol:8006/api2/json"
}

variable "prox_nodes" {
  description = "Array of ProxMox node names"
  type        = list(string)
  default     = ["prox1", "prox2", "prox3"]
}

variable "prox_api_id" {
  description = "The ID of the Proxmox API user"
  type        = string
}

variable "prox_api_token" {
  description = "The token of the Proxmox API user"
  type        = string
}
