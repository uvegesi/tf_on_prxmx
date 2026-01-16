resource "proxmox_virtual_environment_vm" "kube_nodes" {
  # The Magic Loop: Creates one VM for every entry in your .tfvars
  for_each = var.nodes

  name      = each.key
  node_name = var.common.node_name
  vm_id     = each.value.vm_id

  clone {
    vm_id = var.common.template_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk_size
  }

  network_device {
    bridge = var.common.bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.common.gateway
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_key]
    }
  }
}