# =============================================================================
# Module Services OPNsense
# =============================================================================
# Configure les services DHCP et DNS
# Provider: browningluke/opnsense
# =============================================================================

# -----------------------------------------------------------------------------
# Variables - DHCP
# -----------------------------------------------------------------------------

variable "dhcp_servers" {
  description = "Configuration des serveurs DHCP par interface"
  type = list(object({
    interface = string                       # Interface (lan, opt1...)
    enabled   = optional(bool, true)

    # Plage d'adresses
    range_start = string                     # Première IP de la plage
    range_end   = string                     # Dernière IP de la plage

    # Options réseau
    gateway     = optional(string)           # Gateway (défaut: IP de l'interface)
    dns_servers = optional(list(string), []) # Serveurs DNS
    domain      = optional(string)           # Domaine local
    lease_time  = optional(number, 86400)    # Durée du bail en secondes (24h)

    # Options WINS (legacy)
    wins_servers = optional(list(string), [])

    # Options NTP
    ntp_servers = optional(list(string), [])
  }))

  default = []
}

variable "dhcp_reservations" {
  description = "Réservations DHCP (IP fixes par adresse MAC)"
  type = list(object({
    interface   = string                     # Interface DHCP
    mac         = string                     # Adresse MAC (format: 00:11:22:33:44:55)
    ip          = string                     # IP à attribuer
    hostname    = optional(string)           # Nom d'hôte
    description = optional(string)
  }))

  default = []

  validation {
    condition = alltrue([
      for res in var.dhcp_reservations : can(regex("^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$", res.mac))
    ])
    error_message = "Format MAC invalide. Utilisez: 00:11:22:33:44:55"
  }
}

# -----------------------------------------------------------------------------
# Variables - DNS (Unbound)
# -----------------------------------------------------------------------------

variable "dns_enabled" {
  description = "Activer le résolveur DNS (Unbound)"
  type        = bool
  default     = true
}

variable "dns_interfaces" {
  description = "Interfaces sur lesquelles écouter (vide = toutes)"
  type        = list(string)
  default     = []
}

variable "dns_forwarders" {
  description = "Serveurs DNS upstream (forwarders)"
  type = list(object({
    host     = string                        # IP du serveur DNS
    port     = optional(number, 53)          # Port
    domain   = optional(string)              # Domaine spécifique (optionnel)
    priority = optional(number, 10)
  }))

  default = []
}

variable "dns_overrides" {
  description = "Entrées DNS locales (host overrides)"
  type = list(object({
    hostname    = string                     # Nom d'hôte
    domain      = string                     # Domaine
    ip          = string                     # IP associée
    description = optional(string)
  }))

  default = []
}

variable "dns_domain_overrides" {
  description = "Domaines à résoudre via des serveurs spécifiques"
  type = list(object({
    domain      = string                     # Domaine
    server      = string                     # Serveur DNS pour ce domaine
    description = optional(string)
  }))

  default = []
}

# -----------------------------------------------------------------------------
# Serveurs DHCP
# -----------------------------------------------------------------------------

resource "opnsense_dhcp_v4_server" "this" {
  for_each = { for dhcp in var.dhcp_servers : dhcp.interface => dhcp }

  interface = each.value.interface
  enabled   = each.value.enabled

  # Plage
  range_from = each.value.range_start
  range_to   = each.value.range_end

  # Options réseau
  gateway     = each.value.gateway
  dns_servers = each.value.dns_servers
  domain      = each.value.domain
  lease_time  = each.value.lease_time

  # Options additionnelles
  wins_servers = each.value.wins_servers
  ntp_servers  = each.value.ntp_servers
}

# -----------------------------------------------------------------------------
# Réservations DHCP
# -----------------------------------------------------------------------------

resource "opnsense_dhcp_v4_static_map" "this" {
  for_each = { for idx, res in var.dhcp_reservations : "${res.interface}-${res.mac}" => res }

  interface   = each.value.interface
  mac         = each.value.mac
  ipaddr      = each.value.ip
  hostname    = each.value.hostname
  description = coalesce(each.value.description, "Réservation: ${each.value.hostname}")

  depends_on = [opnsense_dhcp_v4_server.this]
}

# -----------------------------------------------------------------------------
# Configuration DNS (Unbound)
# -----------------------------------------------------------------------------

# Forwarders DNS
resource "opnsense_unbound_forward" "this" {
  for_each = { for idx, fwd in var.dns_forwarders : "${fwd.host}-${coalesce(fwd.domain, "all")}" => fwd }

  enabled  = true
  host     = each.value.host
  port     = each.value.port
  domain   = each.value.domain
  priority = each.value.priority
}

# Host Overrides (entrées DNS locales)
resource "opnsense_unbound_host_override" "this" {
  for_each = { for ho in var.dns_overrides : "${ho.hostname}.${ho.domain}" => ho }

  enabled     = true
  hostname    = each.value.hostname
  domain      = each.value.domain
  server      = each.value.ip
  description = each.value.description
}

# Domain Overrides
resource "opnsense_unbound_domain_override" "this" {
  for_each = { for do in var.dns_domain_overrides : do.domain => do }

  enabled     = true
  domain      = each.value.domain
  server      = each.value.server
  description = each.value.description
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "dhcp_servers" {
  description = "Serveurs DHCP configurés"
  value = {
    for iface, dhcp in opnsense_dhcp_v4_server.this : iface => {
      id          = dhcp.id
      interface   = dhcp.interface
      range_from  = dhcp.range_from
      range_to    = dhcp.range_to
    }
  }
}

output "dhcp_reservations" {
  description = "Réservations DHCP créées"
  value = {
    for key, res in opnsense_dhcp_v4_static_map.this : key => {
      id       = res.id
      mac      = res.mac
      ip       = res.ipaddr
      hostname = res.hostname
    }
  }
}

output "dns_overrides" {
  description = "Entrées DNS locales"
  value = {
    for fqdn, ho in opnsense_unbound_host_override.this : fqdn => {
      id       = ho.id
      hostname = ho.hostname
      domain   = ho.domain
      server   = ho.server
    }
  }
}

# -----------------------------------------------------------------------------
# Exemples d'utilisation
# -----------------------------------------------------------------------------
# dhcp_servers = [
#   {
#     interface   = "lan"
#     range_start = "192.168.10.100"
#     range_end   = "192.168.10.200"
#     gateway     = "192.168.10.1"
#     dns_servers = ["192.168.10.1", "1.1.1.1"]
#     domain      = "home.local"
#     lease_time  = 86400
#   }
# ]
#
# dhcp_reservations = [
#   {
#     interface   = "lan"
#     mac         = "00:11:22:33:44:55"
#     ip          = "192.168.10.10"
#     hostname    = "server-web"
#     description = "Serveur web principal"
#   },
#   {
#     interface   = "lan"
#     mac         = "AA:BB:CC:DD:EE:FF"
#     ip          = "192.168.10.11"
#     hostname    = "nas"
#     description = "NAS Synology"
#   }
# ]
#
# dns_forwarders = [
#   { host = "1.1.1.1" },
#   { host = "1.0.0.1" }
# ]
#
# dns_overrides = [
#   {
#     hostname = "server"
#     domain   = "home.local"
#     ip       = "192.168.10.10"
#   },
#   {
#     hostname = "nas"
#     domain   = "home.local"
#     ip       = "192.168.10.11"
#   }
# ]
# -----------------------------------------------------------------------------
