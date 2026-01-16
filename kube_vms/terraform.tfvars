nodes = {
  "kube-master" = {
    vm_id     = 200
    cores     = 2
    memory    = 4096
    disk_size = 10
    ip        = "192.168.1.100/24"
  }

  "kube-worker-01" = {
    vm_id     = 201
    cores     = 4
    memory    = 8192
    disk_size = 15
    ip        = "192.168.1.101/24"
  }

  "kube-worker-02" = {
    vm_id     = 202
    cores     = 4
    memory    = 8192
    disk_size = 15
    ip        = "192.168.1.102/24"
  }
}