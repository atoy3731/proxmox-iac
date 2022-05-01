output "registration_host" {
  description = "Host/IP of the first controlplane node"
  value       = proxmox_vm_qemu.controlplane_first.ssh_host
}