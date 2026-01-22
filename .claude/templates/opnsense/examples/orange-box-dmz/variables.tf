# =============================================================================
# Variables - OPNsense derrière Box Orange
# =============================================================================

# -----------------------------------------------------------------------------
# Provider OPNsense
# -----------------------------------------------------------------------------

variable "opnsense_uri" {
  description = "URL de l'interface OPNsense (ex: https://192.168.10.1)"
  type        = string

  validation {
    condition     = can(regex("^https?://", var.opnsense_uri))
    error_message = "L'URI doit commencer par http:// ou https://"
  }
}

variable "opnsense_api_key" {
  description = "Clé API OPNsense"
  type        = string
  sensitive   = true
}

variable "opnsense_api_secret" {
  description = "Secret API OPNsense"
  type        = string
  sensitive   = true
}

variable "allow_insecure" {
  description = "Autoriser les certificats auto-signés (false en production)"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Interfaces
# -----------------------------------------------------------------------------

variable "wan_device" {
  description = "Device physique pour WAN (ex: vtnet0, em0)"
  type        = string
  default     = "vtnet0"
}

variable "lan_device" {
  description = "Device physique pour LAN (ex: vtnet1, em1)"
  type        = string
  default     = "vtnet1"
}

variable "lan_ip" {
  description = "Adresse IP du LAN OPNsense"
  type        = string
  default     = "192.168.10.1"

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.lan_ip))
    error_message = "Format IP invalide"
  }
}

variable "lan_subnet" {
  description = "Masque de sous-réseau LAN (ex: 24 pour /24)"
  type        = number
  default     = 24

  validation {
    condition     = var.lan_subnet >= 8 && var.lan_subnet <= 30
    error_message = "Le masque doit être entre 8 et 30"
  }
}

# -----------------------------------------------------------------------------
# DHCP
# -----------------------------------------------------------------------------

variable "dhcp_range_start" {
  description = "Première IP de la plage DHCP"
  type        = string
  default     = "192.168.10.100"
}

variable "dhcp_range_end" {
  description = "Dernière IP de la plage DHCP"
  type        = string
  default     = "192.168.10.200"
}

variable "local_domain" {
  description = "Domaine local pour le réseau"
  type        = string
  default     = "home.local"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "home"

  validation {
    condition     = contains(["dev", "staging", "prod", "home", "lab"], var.environment)
    error_message = "Environnement doit être: dev, staging, prod, home, ou lab"
  }
}
