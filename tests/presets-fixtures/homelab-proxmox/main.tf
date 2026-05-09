# Minimal Proxmox-via-Terraform config — fixture for the homelab-proxmox
# preset's detect rule (depFiles: main.tf contains telmate/proxmox).
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}
