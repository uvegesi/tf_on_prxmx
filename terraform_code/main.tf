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

resource "local_file" "ansible_inventory" {
  filename = "./inventory.ini"
  content  = <<-EOT
    [master]
    %{ for name, vm in proxmox_virtual_environment_vm.kube_nodes ~}
    %{ if length(regexall("master", name)) > 0 ~}
    ${name} ansible_host=${split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
    %{ endif ~}
    %{ endfor ~}

    [node]
    %{ for name, vm in proxmox_virtual_environment_vm.kube_nodes ~}
    %{ if length(regexall("worker", name)) > 0 ~}
    ${name} ansible_host=${split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
    %{ endif ~}
    %{ endfor ~}

    [k3s_cluster:children]
    master
    node
  EOT
}