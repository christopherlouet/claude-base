# =============================================================================
# Module Interfaces OPNsense
# =============================================================================
# Configure les interfaces réseau (WAN, LAN, VLANs)
# Provider: browningluke/opnsense
# =============================================================================

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "interfaces" {
  description = "Liste des interfaces à configurer"
  type = list(object({
    name        = string           # Nom logique (wan, lan, opt1, etc.)
    device      = string           # Device physique (vtnet0, vtnet1, etc.)
    description = optional(string) # Description de l'interface
    enabled     = optional(bool, true)

    # Configuration IPv4
    ipv4_type = optional(string, "none") # none, static, dhcp
    ipv4_addr = optional(string)         # IP si static (ex: 192.168.10.1)
    ipv4_mask = optional(number)         # Masque si static (ex: 24)

    # Gateway (pour WAN principalement)
    gateway = optional(string) # Nom du gateway si statique

    # Options
    block_private   = optional(bool, false) # Bloquer réseaux privés (WAN)
    block_bogons    = optional(bool, false) # Bloquer bogons (WAN)
    promiscuous     = optional(bool, false) # Mode promiscuous
    mtu             = optional(number)      # MTU personnalisé
  }))

  default = []

  validation {
    condition = alltrue([
      for iface in var.interfaces : contains(["none", "static", "dhcp"], iface.ipv4_type)
    ])
    error_message = "ipv4_type doit être: none, static, ou dhcp"
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

  # Configuration IPv4
  ipv4_type = each.value.ipv4_type
  ipv4_addr = each.value.ipv4_type == "static" ? each.value.ipv4_addr : null
  ipv4_mask = each.value.ipv4_type == "static" ? each.value.ipv4_mask : null

  # Options sécurité (typiquement pour WAN)
  block_private = each.value.block_private
  block_bogons  = each.value.block_bogons

  # Options avancées
  promiscuous = each.value.promiscuous
  mtu         = each.value.mtu
}

# -----------------------------------------------------------------------------
# Gateways (pour interfaces avec IP statique)
# -----------------------------------------------------------------------------

variable "gateways" {
  description = "Liste des gateways à configurer"
  type = list(object({
    name           = string                    # Nom du gateway
    interface      = string                    # Interface associée
    gateway        = string                    # Adresse IP du gateway
    default        = optional(bool, false)     # Gateway par défaut
    monitor_ip     = optional(string)          # IP de monitoring (ping)
    priority       = optional(number, 255)     # Priorité (0-255)
    weight         = optional(number, 1)       # Poids pour load balancing
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
  description = "Interfaces configurées"
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
  description = "Gateways configurés"
  value = {
    for name, gw in opnsense_gateway.this : name => {
      id        = gw.id
      interface = gw.interface
      gateway   = gw.gateway
    }
  }
}

# -----------------------------------------------------------------------------
# Exemple d'utilisation
# -----------------------------------------------------------------------------
# interfaces = [
#   {
#     name          = "wan"
#     device        = "vtnet0"
#     description   = "WAN - Box Orange"
#     ipv4_type     = "dhcp"
#     block_private = true
#     block_bogons  = true
#   },
#   {
#     name        = "lan"
#     device      = "vtnet1"
#     description = "LAN - Réseau local"
#     ipv4_type   = "static"
#     ipv4_addr   = "192.168.10.1"
#     ipv4_mask   = 24
#   }
# ]
# -----------------------------------------------------------------------------
