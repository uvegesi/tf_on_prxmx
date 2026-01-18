# The structure for your VMs
variable "nodes" {
  description = "Map of Kubernetes nodes to create"
  type = map(object({
    vm_id     = number
    cores     = number
    memory    = number
    disk_size = number
    ip        = string
  }))
}

# Common settings shared by all VMs
variable "common" {
  type = object({
    node_name   = string
    template_id = number
    gateway     = string
    bridge      = string
  })
  default = {
    node_name   = "pve"
    template_id = 9000
    gateway     = "192.168.0.1"
    bridge      = "vmbr0"
  }
}

variable "containers" {
  description = "Map of LXC containers to create"
  type = map(object({
    vm_id     = number
    cores     = number
    memory    = number
    disk_size = number
    ip        = string
    template  = string
  }))
}

# Keep your existing variables
variable "pm_api_url" {}
variable "pm_api_token_id" {}
variable "pm_api_token_secret" {}
variable "ssh_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}