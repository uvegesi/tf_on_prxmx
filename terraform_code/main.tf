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

resource "proxmox_virtual_environment_container" "infra_nodes" {
  for_each = var.containers

  node_name = var.common.node_name
  vm_id     = each.value.vm_id
  unprivileged = true

  network_interface {
    name   = "eth0"
    bridge = var.common.bridge # This should be "vmbr0"
  }

  initialization {
    hostname = each.key
    
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.common.gateway
      }
    }

    user_account {
      #username = "ubuntu"
      keys     = [var.ssh_key]
    }
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    size         = each.value.disk_size
  }

  operating_system {
    template_file_id = each.value.template
    type             = "ubuntu"
  }

  # This allows Docker to run inside the LXC
  features {
    nesting = true
  }
}

resource "local_file" "ansible_inventory_yaml" {
  filename = "${path.module}/../ansible_code/inventory.yml"
  content  = yamlencode(local.ansible_inventory)
}