# =============================================================================
# Variables - OPNsense behind Orange Box
# =============================================================================

# -----------------------------------------------------------------------------
# OPNsense Provider
# -----------------------------------------------------------------------------

variable "opnsense_uri" {
  description = "OPNsense interface URL (e.g.: https://192.168.10.1)"
  type        = string

  validation {
    condition     = can(regex("^https?://", var.opnsense_uri))
    error_message = "URI must start with http:// or https://"
  }
}

variable "opnsense_api_key" {
  description = "OPNsense API key"
  type        = string
  sensitive   = true
}

variable "opnsense_api_secret" {
  description = "OPNsense API secret"
  type        = string
  sensitive   = true
}

variable "allow_insecure" {
  description = "Allow self-signed certificates (false in production)"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Interfaces
# -----------------------------------------------------------------------------

variable "wan_device" {
  description = "Physical device for WAN (e.g.: vtnet0, em0)"
  type        = string
  default     = "vtnet0"
}

variable "lan_device" {
  description = "Physical device for LAN (e.g.: vtnet1, em1)"
  type        = string
  default     = "vtnet1"
}

variable "lan_ip" {
  description = "OPNsense LAN IP address"
  type        = string
  default     = "192.168.10.1"

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.lan_ip))
    error_message = "Invalid IP format"
  }
}

variable "lan_subnet" {
  description = "LAN subnet mask (e.g.: 24 for /24)"
  type        = number
  default     = 24

  validation {
    condition     = var.lan_subnet >= 8 && var.lan_subnet <= 30
    error_message = "Mask must be between 8 and 30"
  }
}

# -----------------------------------------------------------------------------
# DHCP
# -----------------------------------------------------------------------------

variable "dhcp_range_start" {
  description = "First IP of the DHCP range"
  type        = string
  default     = "192.168.10.100"
}

variable "dhcp_range_end" {
  description = "Last IP of the DHCP range"
  type        = string
  default     = "192.168.10.200"
}

variable "local_domain" {
  description = "Local domain for the network"
  type        = string
  default     = "home.local"
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "home"

  validation {
    condition     = contains(["dev", "staging", "prod", "home", "lab"], var.environment)
    error_message = "Environment must be: dev, staging, prod, home, or lab"
  }
}
