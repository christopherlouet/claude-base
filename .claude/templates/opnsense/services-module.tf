# =============================================================================
# OPNsense Services Module
# =============================================================================
# Configures DHCP and DNS services
# Provider: browningluke/opnsense
# =============================================================================

# -----------------------------------------------------------------------------
# Variables - DHCP
# -----------------------------------------------------------------------------

variable "dhcp_servers" {
  description = "DHCP server configuration per interface"
  type = list(object({
    interface = string                       # Interface (lan, opt1...)
    enabled   = optional(bool, true)

    # Address range
    range_start = string                     # First IP of the range
    range_end   = string                     # Last IP of the range

    # Network options
    gateway     = optional(string)           # Gateway (default: interface IP)
    dns_servers = optional(list(string), []) # DNS servers
    domain      = optional(string)           # Local domain
    lease_time  = optional(number, 86400)    # Lease time in seconds (24h)

    # WINS options (legacy)
    wins_servers = optional(list(string), [])

    # NTP options
    ntp_servers = optional(list(string), [])
  }))

  default = []
}

variable "dhcp_reservations" {
  description = "DHCP reservations (fixed IPs per MAC address)"
  type = list(object({
    interface   = string                     # DHCP interface
    mac         = string                     # MAC address (format: 00:11:22:33:44:55)
    ip          = string                     # IP to assign
    hostname    = optional(string)           # Hostname
    description = optional(string)
  }))

  default = []

  validation {
    condition = alltrue([
      for res in var.dhcp_reservations : can(regex("^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$", res.mac))
    ])
    error_message = "Invalid MAC format. Use: 00:11:22:33:44:55"
  }
}

# -----------------------------------------------------------------------------
# Variables - DNS (Unbound)
# -----------------------------------------------------------------------------

variable "dns_enabled" {
  description = "Enable the DNS resolver (Unbound)"
  type        = bool
  default     = true
}

variable "dns_interfaces" {
  description = "Interfaces to listen on (empty = all)"
  type        = list(string)
  default     = []
}

variable "dns_forwarders" {
  description = "Upstream DNS servers (forwarders)"
  type = list(object({
    host     = string                        # DNS server IP
    port     = optional(number, 53)          # Port
    domain   = optional(string)              # Specific domain (optional)
    priority = optional(number, 10)
  }))

  default = []
}

variable "dns_overrides" {
  description = "Local DNS entries (host overrides)"
  type = list(object({
    hostname    = string                     # Hostname
    domain      = string                     # Domain
    ip          = string                     # Associated IP
    description = optional(string)
  }))

  default = []
}

variable "dns_domain_overrides" {
  description = "Domains to resolve via specific servers"
  type = list(object({
    domain      = string                     # Domain
    server      = string                     # DNS server for this domain
    description = optional(string)
  }))

  default = []
}

# -----------------------------------------------------------------------------
# DHCP servers
# -----------------------------------------------------------------------------

resource "opnsense_dhcp_v4_server" "this" {
  for_each = { for dhcp in var.dhcp_servers : dhcp.interface => dhcp }

  interface = each.value.interface
  enabled   = each.value.enabled

  # Range
  range_from = each.value.range_start
  range_to   = each.value.range_end

  # Network options
  gateway     = each.value.gateway
  dns_servers = each.value.dns_servers
  domain      = each.value.domain
  lease_time  = each.value.lease_time

  # Additional options
  wins_servers = each.value.wins_servers
  ntp_servers  = each.value.ntp_servers
}

# -----------------------------------------------------------------------------
# DHCP reservations
# -----------------------------------------------------------------------------

resource "opnsense_dhcp_v4_static_map" "this" {
  for_each = { for idx, res in var.dhcp_reservations : "${res.interface}-${res.mac}" => res }

  interface   = each.value.interface
  mac         = each.value.mac
  ipaddr      = each.value.ip
  hostname    = each.value.hostname
  description = coalesce(each.value.description, "Reservation: ${each.value.hostname}")

  depends_on = [opnsense_dhcp_v4_server.this]
}

# -----------------------------------------------------------------------------
# DNS configuration (Unbound)
# -----------------------------------------------------------------------------

# DNS forwarders
resource "opnsense_unbound_forward" "this" {
  for_each = { for idx, fwd in var.dns_forwarders : "${fwd.host}-${coalesce(fwd.domain, "all")}" => fwd }

  enabled  = true
  host     = each.value.host
  port     = each.value.port
  domain   = each.value.domain
  priority = each.value.priority
}

# Host overrides (local DNS entries)
resource "opnsense_unbound_host_override" "this" {
  for_each = { for ho in var.dns_overrides : "${ho.hostname}.${ho.domain}" => ho }

  enabled     = true
  hostname    = each.value.hostname
  domain      = each.value.domain
  server      = each.value.ip
  description = each.value.description
}

# Domain overrides
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
  description = "Configured DHCP servers"
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
  description = "Created DHCP reservations"
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
  description = "Local DNS entries"
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
# Usage examples
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
#     description = "Main web server"
#   },
#   {
#     interface   = "lan"
#     mac         = "AA:BB:CC:DD:EE:FF"
#     ip          = "192.168.10.11"
#     hostname    = "nas"
#     description = "Synology NAS"
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
