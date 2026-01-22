# =============================================================================
# Module NAT OPNsense
# =============================================================================
# Configure NAT outbound et port forwarding
# Provider: browningluke/opnsense
# =============================================================================

# -----------------------------------------------------------------------------
# Variables - Port Forwarding
# -----------------------------------------------------------------------------

variable "port_forwards" {
  description = "Liste des règles de port forwarding"
  type = list(object({
    name        = string                    # Nom unique
    description = optional(string)          # Description

    # Interface et protocole
    interface = optional(string, "wan")     # Interface source (wan)
    protocol  = optional(string, "tcp")     # tcp, udp, tcp/udp

    # Port externe
    external_port = string                  # Port ou plage (443, 8000:8100)

    # Cible interne
    target_ip   = string                    # IP du serveur interne
    target_port = optional(string)          # Port cible (si différent)

    # Options
    enabled     = optional(bool, true)
    log         = optional(bool, false)
    reflection  = optional(string, "enable") # NAT reflection: enable, disable
    filter_rule = optional(bool, true)       # Créer règle firewall auto
  }))

  default = []
}

# -----------------------------------------------------------------------------
# Variables - NAT Outbound
# -----------------------------------------------------------------------------

variable "nat_outbound_mode" {
  description = "Mode NAT outbound: automatic, hybrid, manual, disabled"
  type        = string
  default     = "automatic"

  validation {
    condition     = contains(["automatic", "hybrid", "manual", "disabled"], var.nat_outbound_mode)
    error_message = "nat_outbound_mode doit être: automatic, hybrid, manual, disabled"
  }
}

variable "nat_outbound_rules" {
  description = "Règles NAT outbound manuelles (mode hybrid ou manual)"
  type = list(object({
    name        = string                      # Nom unique
    description = optional(string)

    # Matching
    interface   = string                      # Interface de sortie (wan)
    protocol    = optional(string, "any")     # tcp, udp, any
    source_net  = string                      # Réseau source (ex: 192.168.10.0/24)
    source_port = optional(string)

    destination_net  = optional(string, "any")
    destination_port = optional(string)

    # Translation
    translation_target = optional(string)     # IP source traduite (défaut: interface)
    translation_port   = optional(string)     # Port traduit

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

  # Source (externe)
  source_net  = "any"
  source_port = each.value.external_port

  # Destination (avant NAT = IP WAN)
  destination_net  = "${each.value.interface}ip"
  destination_port = each.value.external_port

  # Cible (après NAT)
  target     = each.value.target_ip
  local_port = coalesce(each.value.target_port, each.value.external_port)

  # Options
  enabled     = each.value.enabled
  log         = each.value.log
  description = coalesce(each.value.description, "Port forward: ${each.value.name}")

  # NAT reflection pour accès local
  nat_reflection = each.value.reflection

  # Créer règle firewall associée automatiquement
  filter_rule_association = each.value.filter_rule ? "add-associated" : "none"
}

# -----------------------------------------------------------------------------
# NAT Outbound (si mode != automatic)
# -----------------------------------------------------------------------------

# Note: La configuration du mode outbound dépend de l'API OPNsense
# En mode automatic, OPNsense gère automatiquement le NAT outbound

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
  description = "Règles de port forwarding créées"
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
  description = "Règles NAT outbound créées"
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
# Exemples d'utilisation
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
#     description   = "HTTPS vers serveur web"
#   },
#   {
#     name          = "ssh_to_server"
#     interface     = "wan"
#     protocol      = "tcp"
#     external_port = "2222"
#     target_ip     = "192.168.10.10"
#     target_port   = "22"
#     description   = "SSH vers serveur (port non-standard)"
#   }
# ]
#
# # NAT outbound manuel (optionnel, automatic suffit généralement)
# nat_outbound_mode = "hybrid"
# nat_outbound_rules = [
#   {
#     name       = "lan_to_wan"
#     interface  = "wan"
#     source_net = "192.168.10.0/24"
#     description = "NAT LAN vers WAN"
#   }
# ]
# -----------------------------------------------------------------------------
