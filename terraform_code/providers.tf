terraform {
  cloud {
    organization = "istvan_1"

    workspaces {
      name = "proxmox-kube-lab"
    }
  }

  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.93.0"
    }
  }
}

provider "proxmox" {
    endpoint = var.pm_api_url
    api_token = "${var.pm_api_token_id}=${var.pm_api_token_secret}"
    insecure = true

    ssh {
        agent = true
    }
#   pm_api_url          = var.pm_api_url
#   pm_api_token_id     = var.pm_api_token_id
#   pm_api_token_secret = var.pm_api_token_secret
#   pm_tls_insecure     = true

#   # CRITICAL SETTINGS FOR HOME LABS
#   pm_timeout          = 1200       # Give it 20 minutes (not 60 seconds)
#   pm_parallel         = 1          # Create VMs one by one (safer for disk I/O)
}