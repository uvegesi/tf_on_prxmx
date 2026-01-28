# Terraform & Ansible on Proxmox - Infrastructure as Code

This project automates the provisioning and configuration of a complete infrastructure stack on Proxmox using Terraform and Ansible. It deploys a K3s Kubernetes cluster, Vault secret management, Tailscale networking, and GitHub Actions runners.

## Overview

The infrastructure consists of:

- **Terraform** - Provisions VMs and LXC containers on a Proxmox cluster
- **Ansible** - Configures the infrastructure with desired state
- **K3s** - Lightweight Kubernetes cluster for container orchestration
- **Vault** - Secret and encryption management
- **Tailscale** - Secure networking overlay
- **GitHub Runner** - Self-hosted CI/CD runner for GitHub Actions

## Architecture

- **K3s Master/Workers** (VMs) — Kubernetes control and compute
- **Vault** (LXC) — secrets storage
- **GitHub Runner** (LXC) — CI/CD

### Network

Internal bridge (e.g., `192.168.0.0/24`) plus a Tailscale overlay for secure access (SSH via Tailscale/jump host).

## Prerequisites

- **Local**: Terraform >=1.0, Ansible >=2.9, SSH key (`~/.ssh/id_rsa_pve`)
- **Proxmox**: API access, VM template, bridge network and storage

Set credentials in `terraform_code/secrets.tfvars` or via env vars, e.g.:

```hcl
pm_api_url = "https://your-proxmox-ip:8006"
pm_api_token_id = "terraform@pam!terraform"
pm_api_token_secret = "your-api-token"
ssh_key = "ssh-rsa AAAA..."
```

## Project Structure

```
tf_on_prxmx/
├── terraform_code/          # Infrastructure provisioning
│   ├── main.tf             # VM and container resources
│   ├── variables.tf        # Input variable definitions
│   ├── providers.tf        # Provider configuration
│   ├── locals.tf           # Local values
│   ├── data.tf             # Data sources
│   ├── terraform.tfvars    # Common variables
│   └── secrets.tfvars      # Sensitive data (gitignored)
│
└── ansible_code/           # Infrastructure configuration
    ├── site.yml            # Main playbook
    ├── inventory.yml       # Host inventory
    ├── ansible.cfg         # Ansible configuration
    ├── .vault_pass         # Vault password (gitignored) Create it locally to store your Ansible Vault password.
    ├── group_vars/
    │   └── all/
    │       ├── vars.yml    # Common variables
    │       └── secrets.yml # Encrypted secrets (ansible-vault)
    └── roles/              # Ansible roles
        ├── common/         # System preparation
        ├── k3s_master/     # K3s control plane
        ├── k3s_worker/     # K3s worker nodes
        ├── vault_server/   # Vault setup
        ├── tailscale/      # Tailscale overlay
        └── github_runner/  # GitHub Actions runner
```

## Quick Start

1. Configure `terraform_code/secrets.tfvars` with credentials.
2. Provision: 
```bash
cd terraform_code
terraform init
terraform apply -var-file=secrets.tfvars
```
3. Configure services:
```bash
cd ../ansible_code
ansible-playbook site.yml --vault-password-file=.vault_pass
```
Access nodes via Tailscale: `ssh -i ~/.ssh/id_rsa_pve ubuntu@kube-master`

## Configuration

- Terraform: edit `terraform_code/terraform.tfvars` to define nodes/containers (vm_id, resources, IPs).
- Ansible: edit `ansible_code/group_vars/all/vars.yml` for service settings (K3s, Vault, GitHub runner).
- Secrets: edit `ansible_code/group_vars/all/secrets.yml` with `ansible-vault edit`.

## Ansible Playbooks

```bash
ansible-playbook site.yml                              # full setup
ansible-playbook site.yml --tags k3s_master,k3s_worker # k3s only
ansible-playbook site.yml --tags vault                 # vault only
```

## Ansible Roles

- `common` — system prep
- `k3s_master` / `k3s_worker` — Kubernetes
- `vault_server` — Vault setup
- `tailscale` — Tailscale
- `github_runner` — GitHub Actions runner

## Managing Secrets

- Vault: `vault login` → `vault kv put/get secret/name`
- Ansible Vault: `ansible-vault edit|view|encrypt`, e.g. `ansible-vault edit ansible_code/group_vars/all/secrets.yml`

## Troubleshooting

- **Terraform**: check Proxmox API endpoint, token, and firewall
- **Ansible/SSH**: verify `terraform output`, inventory IPs, and Tailscale/SSH access
- **K3s**: check master token and `journalctl -u k3s`
- **Vault**: check `journalctl -u vault` and data directory permissions

## Maintenance

- **Scale:** add nodes in `terraform.tfvars` → `terraform apply` → `ansible-playbook site.yml --tags k3s_worker`
- **Backup:** `rsync -av vault-server:/mnt/vault/data ./backups/`
- **Destroy:** `terraform destroy -var-file=secrets.tfvars`
