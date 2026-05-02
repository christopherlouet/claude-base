# =============================================================================
# Template: Proxmox Provider Configuration
# Usage: Copy to the root of your Terraform Proxmox project
# Provider: bpg/proxmox >= 0.50
# =============================================================================

# -----------------------------------------------------------------------------
# Required versions and providers
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }

  # Recommended backend for state
  # Uncomment and configure based on your environment
  #
  # backend "s3" {
  #   bucket         = "terraform-state"
  #   key            = "proxmox/terraform.tfstate"
  #   region         = "eu-west-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
  #
  # OR local backend (dev only)
  #
  # backend "local" {
  #   path = "terraform.tfstate"
  # }
}

# -----------------------------------------------------------------------------
# Provider variables
# -----------------------------------------------------------------------------

variable "proxmox_endpoint" {
  description = "Proxmox API URL (e.g., https://pve.example.com:8006)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token (format: user@realm!tokenid=secret)"
  type        = string
  sensitive   = true
  default     = null
}

variable "proxmox_username" {
  description = "Proxmox username (alternative to token)"
  type        = string
  default     = null
}

variable "proxmox_password" {
  description = "Proxmox password (alternative to token)"
  type        = string
  sensitive   = true
  default     = null
}

variable "proxmox_insecure" {
  description = "Skip SSL verification (dev only)"
  type        = bool
  default     = false
}

variable "ssh_agent" {
  description = "Use the local SSH agent"
  type        = bool
  default     = true
}

variable "ssh_username" {
  description = "SSH username for Proxmox nodes"
  type        = string
  default     = "root"
}

# -----------------------------------------------------------------------------
# Proxmox provider
# -----------------------------------------------------------------------------

provider "proxmox" {
  endpoint = var.proxmox_endpoint

  # Authentication via API token (recommended)
  api_token = var.proxmox_api_token

  # OR authentication via username/password
  # username = var.proxmox_username
  # password = var.proxmox_password

  # SSL
  insecure = var.proxmox_insecure

  # SSH configuration (required for some operations)
  ssh {
    agent    = var.ssh_agent
    username = var.ssh_username
  }
}

# -----------------------------------------------------------------------------
# Useful data sources
# -----------------------------------------------------------------------------

# Retrieve cluster information
data "proxmox_virtual_environment_nodes" "available" {}

# Retrieve available datastores
data "proxmox_virtual_environment_datastores" "available" {
  node_name = data.proxmox_virtual_environment_nodes.available.names[0]
}

# -----------------------------------------------------------------------------
# Informational outputs
# -----------------------------------------------------------------------------

output "proxmox_nodes" {
  description = "Available Proxmox nodes"
  value       = data.proxmox_virtual_environment_nodes.available.names
}

output "proxmox_datastores" {
  description = "Available datastores"
  value       = [for ds in data.proxmox_virtual_environment_datastores.available.datastore_ids : ds]
}

# -----------------------------------------------------------------------------
# Example terraform.tfvars file
# -----------------------------------------------------------------------------

# Create a terraform.tfvars file (DO NOT COMMIT):
#
# proxmox_endpoint  = "https://pve.example.com:8006"
# proxmox_api_token = "terraform@pve!terraform-token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# proxmox_insecure  = true  # false in production with a valid certificate
#
# OR with username/password:
#
# proxmox_endpoint = "https://pve.example.com:8006"
# proxmox_username = "root@pam"
# proxmox_password = "secret"

# -----------------------------------------------------------------------------
# Alternative environment variables
# -----------------------------------------------------------------------------

# You can also use environment variables:
#
# export PROXMOX_VE_ENDPOINT="https://pve.example.com:8006"
# export PROXMOX_VE_API_TOKEN="terraform@pve!terraform-token=xxx"
# export PROXMOX_VE_INSECURE="true"
