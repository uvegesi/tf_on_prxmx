locals {
  # 1. Extract Master Hosts
  master_hosts = {
    for name, vm in proxmox_virtual_environment_vm.kube_nodes :
    name => {
      ansible_host = split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]
      ansible_user = "ubuntu" # Set user at the host/group level
    }
    if strcontains(name, "master")
  }

  # 2. Extract Worker Hosts
  worker_hosts = {
    for name, vm in proxmox_virtual_environment_vm.kube_nodes :
    name => {
      ansible_host = split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]
      ansible_user = "ubuntu" # Set user at the host/group level
    }
    if strcontains(name, "worker")
  }

  # 3. Extract Vault Host
  vault_hosts = {
    for name, lxc in proxmox_virtual_environment_container.infra_nodes :
    name => {
      ansible_host = split("/", var.containers[name].ip)[0]
      ansible_user = "root"   # LXC uses root
    }
    if strcontains(name, "vault")
  }

  ansible_inventory = {
    all = {
      vars = {
        ansible_ssh_private_key_file = "~/.ssh/id_rsa_pve"
        # Added StrictHostKeyChecking=no to prevent automated runs from hanging
        ansible_ssh_common_args      = "-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -i ~/.ssh/id_rsa_pve -o StrictHostKeyChecking=no -W %h:%p -q root@100.122.87.80\""
      }
      children = {
        master = { hosts = local.master_hosts }
        node   = { hosts = local.worker_hosts }
        vault  = { hosts = local.vault_hosts }

        k3s_cluster = {
          children = {
            master = {}
            node   = {}
          }
        }
      }
    }
  }
}