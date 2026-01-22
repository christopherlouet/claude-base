# =============================================================================
# Provider OPNsense - Template de configuration
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
# Configuration du provider OPNsense
# -----------------------------------------------------------------------------
# IMPORTANT: Ne jamais hardcoder les credentials
# Utiliser des variables d'environnement ou terraform.tfvars (non commité)
# -----------------------------------------------------------------------------

provider "opnsense" {
  uri = var.opnsense_uri

  # Authentification API
  api_key    = var.opnsense_api_key
  api_secret = var.opnsense_api_secret

  # Options de connexion
  allow_insecure = var.opnsense_allow_insecure # false en production
}

# -----------------------------------------------------------------------------
# Variables pour le provider
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
  description = "Clé API OPNsense (générer dans System > Access > Users)"
  type        = string
  sensitive   = true
}

variable "opnsense_api_secret" {
  description = "Secret API OPNsense"
  type        = string
  sensitive   = true
}

variable "opnsense_allow_insecure" {
  description = "Autoriser les certificats auto-signés (false en production)"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Configuration des credentials via environnement (recommandé)
# -----------------------------------------------------------------------------
# export TF_VAR_opnsense_uri="https://192.168.10.1"
# export TF_VAR_opnsense_api_key="votre-api-key"
# export TF_VAR_opnsense_api_secret="votre-api-secret"
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Exemple terraform.tfvars (NE PAS COMMITER - ajouter à .gitignore)
# -----------------------------------------------------------------------------
# opnsense_uri            = "https://192.168.10.1"
# opnsense_api_key        = "votre-api-key"
# opnsense_api_secret     = "votre-api-secret"
# opnsense_allow_insecure = true  # false en production
# -----------------------------------------------------------------------------
