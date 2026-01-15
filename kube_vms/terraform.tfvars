# terraform.tfvars
gateway = "192.168.1.1"

k8s_nodes = {
  "kube-master" = {
    vmid   = 200
    ip     = "192.168.1.100"
    cores  = 2
    memory = 4096
    disk   = "10G"
  }
  "kube-worker-01" = {
    vmid   = 201
    ip     = "192.168.1.101"
    cores  = 4
    memory = 8192
    disk   = "15G"
  }
  "kube-worker-02" = {
    vmid   = 202
    ip     = "192.168.1.102"
    cores  = 4
    memory = 8192
    disk   = "15G"
  }
}