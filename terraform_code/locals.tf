locals {
  master_hosts = {
    for name, vm in proxmox_virtual_environment_vm.kube_nodes :
    name => {
      ansible_host = split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]
    }
    if strcontains(name, "master")
  }

  worker_hosts = {
    for name, vm in proxmox_virtual_environment_vm.kube_nodes :
    name => {
      ansible_host = split("/", vm.initialization[0].ip_config[0].ipv4[0].address)[0]
    }
    if strcontains(name, "worker")
  }

  ansible_inventory = {
    all = {
      vars = {
        ansible_user                 = "ubuntu"
        ansible_ssh_private_key_file = "~/.ssh/id_rsa_pve"
        ansible_ssh_common_args      = "-o ProxyCommand=\"ssh -i ~/.ssh/id_rsa_pve -W %h:%p -q root@100.122.87.80\""
      }
      children = {
        master = { hosts = local.master_hosts }
        node   = { hosts = local.worker_hosts }

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