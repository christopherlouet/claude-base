# =============================================================================
# OPNsense Interfaces Module
# =============================================================================
# Configures network interfaces (WAN, LAN, VLANs)
# Provider: browningluke/opnsense
# =============================================================================

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "interfaces" {
  description = "List of interfaces to configure"
  type = list(object({
    name        = string           # Logical name (wan, lan, opt1, etc.)
    device      = string           # Physical device (vtnet0, vtnet1, etc.)
    description = optional(string) # Interface description
    enabled     = optional(bool, true)

    # IPv4 configuration
    ipv4_type = optional(string, "none") # none, static, dhcp
    ipv4_addr = optional(string)         # IP if static (e.g.: 192.168.10.1)
    ipv4_mask = optional(number)         # Mask if static (e.g.: 24)

    # Gateway (mainly for WAN)
    gateway = optional(string) # Gateway name if static

    # Options
    block_private   = optional(bool, false) # Block private networks (WAN)
    block_bogons    = optional(bool, false) # Block bogons (WAN)
    promiscuous     = optional(bool, false) # Promiscuous mode
    mtu             = optional(number)      # Custom MTU
  }))

  default = []

  validation {
    condition = alltrue([
      for iface in var.interfaces : contains(["none", "static", "dhcp"], iface.ipv4_type)
    ])
    error_message = "ipv4_type must be: none, static, or dhcp"
  }
}

# -----------------------------------------------------------------------------
# Interfaces
# -----------------------------------------------------------------------------

resource "opnsense_interface" "this" {
  for_each = { for iface in var.interfaces : iface.name => iface }

  device      = each.value.device
  description = coalesce(each.value.description, upper(each.value.name))
  enabled     = each.value.enabled

  # IPv4 configuration
  ipv4_type = each.value.ipv4_type
  ipv4_addr = each.value.ipv4_type == "static" ? each.value.ipv4_addr : null
  ipv4_mask = each.value.ipv4_type == "static" ? each.value.ipv4_mask : null

  # Security options (typically for WAN)
  block_private = each.value.block_private
  block_bogons  = each.value.block_bogons

  # Advanced options
  promiscuous = each.value.promiscuous
  mtu         = each.value.mtu
}

# -----------------------------------------------------------------------------
# Gateways (for interfaces with static IP)
# -----------------------------------------------------------------------------

variable "gateways" {
  description = "List of gateways to configure"
  type = list(object({
    name           = string                    # Gateway name
    interface      = string                    # Associated interface
    gateway        = string                    # Gateway IP address
    default        = optional(bool, false)     # Default gateway
    monitor_ip     = optional(string)          # Monitoring IP (ping)
    priority       = optional(number, 255)     # Priority (0-255)
    weight         = optional(number, 1)       # Weight for load balancing
    description    = optional(string)
  }))

  default = []
}

resource "opnsense_gateway" "this" {
  for_each = { for gw in var.gateways : gw.name => gw }

  name           = each.value.name
  interface      = each.value.interface
  gateway        = each.value.gateway
  default_gw     = each.value.default
  monitor        = each.value.monitor_ip
  priority       = each.value.priority
  weight         = each.value.weight
  description    = each.value.description

  depends_on = [opnsense_interface.this]
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "interfaces" {
  description = "Configured interfaces"
  value = {
    for name, iface in opnsense_interface.this : name => {
      id          = iface.id
      device      = iface.device
      description = iface.description
      ipv4_addr   = iface.ipv4_addr
      ipv4_mask   = iface.ipv4_mask
    }
  }
}

output "gateways" {
  description = "Configured gateways"
  value = {
    for name, gw in opnsense_gateway.this : name => {
      id        = gw.id
      interface = gw.interface
      gateway   = gw.gateway
    }
  }
}

# -----------------------------------------------------------------------------
# Usage example
# -----------------------------------------------------------------------------
# interfaces = [
#   {
#     name          = "wan"
#     device        = "vtnet0"
#     description   = "WAN - Orange Box"
#     ipv4_type     = "dhcp"
#     block_private = true
#     block_bogons  = true
#   },
#   {
#     name        = "lan"
#     device      = "vtnet1"
#     description = "LAN - Local network"
#     ipv4_type   = "static"
#     ipv4_addr   = "192.168.10.1"
#     ipv4_mask   = 24
#   }
# ]
# -----------------------------------------------------------------------------
