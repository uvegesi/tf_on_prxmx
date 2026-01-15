resource "proxmox_vm_qemu" "k8s_nodes" {
  for_each = var.k8s_nodes

  name        = each.key        # "k8s-master", "k8s-worker-01", etc.
  vmid        = each.value.vmid # 200, 201, etc.
  target_node = "pve"
  clone       = "ubuntu-2404-template"

  agent   = 1
  cores   = each.value.cores # 2 or 4
  sockets = 1
  cpu     = "host"
  memory  = each.value.memory # 4096 or 8192

  disk {
    storage = "local-lvm"
    type    = "scsi"
    size    = each.value.disk # "20G" or "40G"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  os_type = "cloud-init"
  ciuser  = "ubuntu"
  sshkeys = var.ssh_key

  # Dynamic IP Injection
  # format() helps to construct the string safely
  ipconfig0 = format("ip=%s/24,gw=%s", each.value.ip, var.gateway)
}