nodes = {
  "kube-master" = {
    vm_id     = 200
    cores     = 2
    memory    = 4096
    disk_size = 10
    ip        = "192.168.0.200/24"
  }

  "kube-worker-01" = {
    vm_id     = 201
    cores     = 4
    memory    = 8192
    disk_size = 15
    ip        = "192.168.0.201/24"
  }

  "kube-worker-02" = {
    vm_id     = 202
    cores     = 4
    memory    = 8192
    disk_size = 15
    ip        = "192.168.0.202/24"
  }
}

containers = {
  "vault-server" = {
    vm_id     = 300
    cores     = 1
    memory    = 1024
    disk_size = 8
    ip        = "192.168.0.203/24"
    template  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  }
}