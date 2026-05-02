# =============================================================================
# OPNsense NAT Module
# =============================================================================
# Configure NAT outbound and port forwarding
# Provider: browningluke/opnsense
# =============================================================================

# -----------------------------------------------------------------------------
# Variables - Port Forwarding
# -----------------------------------------------------------------------------

variable "port_forwards" {
  description = "List of port forwarding rules"
  type = list(object({
    name        = string                    # Unique name
    description = optional(string)          # Description

    # Interface and protocol
    interface = optional(string, "wan")     # Source interface (wan)
    protocol  = optional(string, "tcp")     # tcp, udp, tcp/udp

    # External port
    external_port = string                  # Port or range (443, 8000:8100)

    # Internal target
    target_ip   = string                    # Internal server IP
    target_port = optional(string)          # Target port (if different)

    # Options
    enabled     = optional(bool, true)
    log         = optional(bool, false)
    reflection  = optional(string, "enable") # NAT reflection: enable, disable
    filter_rule = optional(bool, true)       # Auto-create firewall rule
  }))

  default = []
}

# -----------------------------------------------------------------------------
# Variables - NAT Outbound
# -----------------------------------------------------------------------------

variable "nat_outbound_mode" {
  description = "NAT outbound mode: automatic, hybrid, manual, disabled"
  type        = string
  default     = "automatic"

  validation {
    condition     = contains(["automatic", "hybrid", "manual", "disabled"], var.nat_outbound_mode)
    error_message = "nat_outbound_mode must be: automatic, hybrid, manual, disabled"
  }
}

variable "nat_outbound_rules" {
  description = "Manual NAT outbound rules (hybrid or manual mode)"
  type = list(object({
    name        = string                      # Unique name
    description = optional(string)

    # Matching
    interface   = string                      # Outbound interface (wan)
    protocol    = optional(string, "any")     # tcp, udp, any
    source_net  = string                      # Source network (e.g., 192.168.10.0/24)
    source_port = optional(string)

    destination_net  = optional(string, "any")
    destination_port = optional(string)

    # Translation
    translation_target = optional(string)     # Translated source IP (default: interface)
    translation_port   = optional(string)     # Translated port

    # Options
    enabled  = optional(bool, true)
    log      = optional(bool, false)
    sequence = optional(number)
  }))

  default = []
}

# -----------------------------------------------------------------------------
# Port Forwarding
# -----------------------------------------------------------------------------

resource "opnsense_nat_port_forward" "this" {
  for_each = { for pf in var.port_forwards : pf.name => pf }

  interface = each.value.interface
  protocol  = each.value.protocol

  # Source (external)
  source_net  = "any"
  source_port = each.value.external_port

  # Destination (before NAT = WAN IP)
  destination_net  = "${each.value.interface}ip"
  destination_port = each.value.external_port

  # Target (after NAT)
  target     = each.value.target_ip
  local_port = coalesce(each.value.target_port, each.value.external_port)

  # Options
  enabled     = each.value.enabled
  log         = each.value.log
  description = coalesce(each.value.description, "Port forward: ${each.value.name}")

  # NAT reflection for local access
  nat_reflection = each.value.reflection

  # Auto-create associated firewall rule
  filter_rule_association = each.value.filter_rule ? "add-associated" : "none"
}

# -----------------------------------------------------------------------------
# NAT Outbound (if mode != automatic)
# -----------------------------------------------------------------------------

# Note: Outbound mode configuration depends on the OPNsense API
# In automatic mode, OPNsense automatically manages NAT outbound

resource "opnsense_nat_outbound" "this" {
  for_each = var.nat_outbound_mode != "automatic" ? {
    for rule in var.nat_outbound_rules : rule.name => rule
  } : {}

  interface = each.value.interface
  protocol  = each.value.protocol

  source_net  = each.value.source_net
  source_port = each.value.source_port

  destination_net  = each.value.destination_net
  destination_port = each.value.destination_port

  # Translation
  target      = each.value.translation_target
  target_port = each.value.translation_port

  # Options
  enabled     = each.value.enabled
  log         = each.value.log
  sequence    = each.value.sequence
  description = coalesce(each.value.description, "NAT outbound: ${each.value.name}")
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "port_forwards" {
  description = "Created port forwarding rules"
  value = {
    for name, pf in opnsense_nat_port_forward.this : name => {
      id            = pf.id
      interface     = pf.interface
      external_port = pf.source_port
      target        = pf.target
      local_port    = pf.local_port
      description   = pf.description
    }
  }
}

output "nat_outbound_rules" {
  description = "Created NAT outbound rules"
  value = var.nat_outbound_mode != "automatic" ? {
    for name, rule in opnsense_nat_outbound.this : name => {
      id          = rule.id
      interface   = rule.interface
      source_net  = rule.source_net
      description = rule.description
    }
  } : {}
}

# -----------------------------------------------------------------------------
# Usage examples
# -----------------------------------------------------------------------------
# # Port forwarding
# port_forwards = [
#   {
#     name          = "https_to_webserver"
#     interface     = "wan"
#     protocol      = "tcp"
#     external_port = "443"
#     target_ip     = "192.168.10.20"
#     target_port   = "443"
#     description   = "HTTPS to web server"
#   },
#   {
#     name          = "ssh_to_server"
#     interface     = "wan"
#     protocol      = "tcp"
#     external_port = "2222"
#     target_ip     = "192.168.10.10"
#     target_port   = "22"
#     description   = "SSH to server (non-standard port)"
#   }
# ]
#
# # Manual NAT outbound (optional, automatic is usually enough)
# nat_outbound_mode = "hybrid"
# nat_outbound_rules = [
#   {
#     name       = "lan_to_wan"
#     interface  = "wan"
#     source_net = "192.168.10.0/24"
#     description = "NAT LAN to WAN"
#   }
# ]
# -----------------------------------------------------------------------------
