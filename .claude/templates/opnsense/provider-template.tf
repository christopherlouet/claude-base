# =============================================================================
# OPNsense Provider - Configuration template
# =============================================================================
# Provider: browningluke/opnsense
# Documentation: https://registry.terraform.io/providers/browningluke/opnsense/latest/docs
# =============================================================================

terraform {
  required_version = "~> 1.9"

  required_providers {
    opnsense = {
      source  = "browningluke/opnsense"
      version = "~> 0.11"
    }
  }
}

# -----------------------------------------------------------------------------
# OPNsense provider configuration
# -----------------------------------------------------------------------------
# IMPORTANT: Never hardcode credentials
# Use environment variables or terraform.tfvars (not committed)
# -----------------------------------------------------------------------------

provider "opnsense" {
  uri = var.opnsense_uri

  # API authentication
  api_key    = var.opnsense_api_key
  api_secret = var.opnsense_api_secret

  # Connection options
  allow_insecure = var.opnsense_allow_insecure # false in production
}

# -----------------------------------------------------------------------------
# Provider variables
# -----------------------------------------------------------------------------

variable "opnsense_uri" {
  description = "OPNsense interface URL (e.g.: https://192.168.10.1)"
  type        = string

  validation {
    condition     = can(regex("^https?://", var.opnsense_uri))
    error_message = "The URI must start with http:// or https://"
  }
}

variable "opnsense_api_key" {
  description = "OPNsense API key (generate in System > Access > Users)"
  type        = string
  sensitive   = true
}

variable "opnsense_api_secret" {
  description = "OPNsense API secret"
  type        = string
  sensitive   = true
}

variable "opnsense_allow_insecure" {
  description = "Allow self-signed certificates (false in production)"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Configuring credentials via environment (recommended)
# -----------------------------------------------------------------------------
# export TF_VAR_opnsense_uri="https://192.168.10.1"
# export TF_VAR_opnsense_api_key="your-api-key"
# export TF_VAR_opnsense_api_secret="your-api-secret"
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Example terraform.tfvars (DO NOT COMMIT - add to .gitignore)
# -----------------------------------------------------------------------------
# opnsense_uri            = "https://192.168.10.1"
# opnsense_api_key        = "your-api-key"
# opnsense_api_secret     = "your-api-secret"
# opnsense_allow_insecure = true  # false in production
# -----------------------------------------------------------------------------
