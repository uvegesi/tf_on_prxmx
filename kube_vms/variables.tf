variable "pm_api_url" {
  type = string
}

variable "pm_api_token_id" {
  type = string
}

variable "pm_api_token_secret" {
  type      = string
  sensitive = true
}

variable "pm_timeout" {
  type    = number
  default = 60
}

variable "ssh_key" {
  type = string
  sensitive = true
}

variable "gateway" {
  type    = string
  default = "192.168.1.1"
}

# The Configuration Map
variable "k8s_nodes" {
  description = "Configuration for Kubernetes Nodes"
  type = map(object({
    vmid   = number
    ip     = string
    cores  = number
    memory = number
    disk   = string
  }))
}