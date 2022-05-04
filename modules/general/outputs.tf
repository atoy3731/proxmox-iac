output "node_ips" {
  description = "Node IPs"
  value       = proxmox_vm_qemu.nodes[*].ssh_host
}