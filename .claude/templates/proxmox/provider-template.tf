# =============================================================================
# Template: Configuration Provider Proxmox
# Usage: Copier à la racine de votre projet Terraform Proxmox
# Provider: bpg/proxmox >= 0.50
# =============================================================================

# -----------------------------------------------------------------------------
# Versions et providers requis
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }

  # Backend recommandé pour le state
  # Décommenter et configurer selon votre environnement
  #
  # backend "s3" {
  #   bucket         = "terraform-state"
  #   key            = "proxmox/terraform.tfstate"
  #   region         = "eu-west-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
  #
  # OU backend local (dev only)
  #
  # backend "local" {
  #   path = "terraform.tfstate"
  # }
}

# -----------------------------------------------------------------------------
# Variables du provider
# -----------------------------------------------------------------------------

variable "proxmox_endpoint" {
  description = "URL de l'API Proxmox (ex: https://pve.example.com:8006)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Token API Proxmox (format: user@realm!tokenid=secret)"
  type        = string
  sensitive   = true
  default     = null
}

variable "proxmox_username" {
  description = "Username Proxmox (alternative au token)"
  type        = string
  default     = null
}

variable "proxmox_password" {
  description = "Password Proxmox (alternative au token)"
  type        = string
  sensitive   = true
  default     = null
}

variable "proxmox_insecure" {
  description = "Ignorer la vérification SSL (dev only)"
  type        = bool
  default     = false
}

variable "ssh_agent" {
  description = "Utiliser l'agent SSH local"
  type        = bool
  default     = true
}

variable "ssh_username" {
  description = "Username SSH pour les nodes Proxmox"
  type        = string
  default     = "root"
}

# -----------------------------------------------------------------------------
# Provider Proxmox
# -----------------------------------------------------------------------------

provider "proxmox" {
  endpoint = var.proxmox_endpoint

  # Authentification par token API (recommandé)
  api_token = var.proxmox_api_token

  # OU authentification par username/password
  # username = var.proxmox_username
  # password = var.proxmox_password

  # SSL
  insecure = var.proxmox_insecure

  # Configuration SSH (nécessaire pour certaines opérations)
  ssh {
    agent    = var.ssh_agent
    username = var.ssh_username
  }
}

# -----------------------------------------------------------------------------
# Data sources utiles
# -----------------------------------------------------------------------------

# Récupérer les informations du cluster
data "proxmox_virtual_environment_nodes" "available" {}

# Récupérer les datastores disponibles
data "proxmox_virtual_environment_datastores" "available" {
  node_name = data.proxmox_virtual_environment_nodes.available.names[0]
}

# -----------------------------------------------------------------------------
# Outputs informatifs
# -----------------------------------------------------------------------------

output "proxmox_nodes" {
  description = "Nodes Proxmox disponibles"
  value       = data.proxmox_virtual_environment_nodes.available.names
}

output "proxmox_datastores" {
  description = "Datastores disponibles"
  value       = [for ds in data.proxmox_virtual_environment_datastores.available.datastore_ids : ds]
}

# -----------------------------------------------------------------------------
# Exemple de fichier terraform.tfvars
# -----------------------------------------------------------------------------

# Créer un fichier terraform.tfvars (NE PAS COMMITER) :
#
# proxmox_endpoint  = "https://pve.example.com:8006"
# proxmox_api_token = "terraform@pve!terraform-token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# proxmox_insecure  = true  # false en production avec certificat valide
#
# OU avec username/password :
#
# proxmox_endpoint = "https://pve.example.com:8006"
# proxmox_username = "root@pam"
# proxmox_password = "secret"

# -----------------------------------------------------------------------------
# Variables d'environnement alternatives
# -----------------------------------------------------------------------------

# Vous pouvez aussi utiliser des variables d'environnement :
#
# export PROXMOX_VE_ENDPOINT="https://pve.example.com:8006"
# export PROXMOX_VE_API_TOKEN="terraform@pve!terraform-token=xxx"
# export PROXMOX_VE_INSECURE="true"
