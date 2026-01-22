# =============================================================================
# Module Firewall OPNsense
# =============================================================================
# Configure les règles de pare-feu
# Provider: browningluke/opnsense
# =============================================================================

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "firewall_rules" {
  description = "Liste des règles de pare-feu"
  type = list(object({
    # Identifiant
    name        = string                     # Nom unique de la règle
    description = optional(string)           # Description

    # Matching
    interface   = string                     # Interface (wan, lan, opt1...)
    direction   = optional(string, "in")     # in, out
    ip_protocol = optional(string, "inet")   # inet (IPv4), inet6 (IPv6)
    protocol    = optional(string, "any")    # tcp, udp, icmp, any, etc.

    # Source
    source_net    = optional(string, "any")  # IP, réseau, alias, ou "any"
    source_port   = optional(string)         # Port source (rare)
    source_invert = optional(bool, false)    # Inverser la source

    # Destination
    destination_net    = optional(string, "any") # IP, réseau, alias, "(self)"
    destination_port   = optional(string)        # Port ou plage (80, 80:443)
    destination_invert = optional(bool, false)   # Inverser la destination

    # Action
    action   = optional(string, "pass")      # pass, block, reject
    log      = optional(bool, false)         # Logger les correspondances
    sequence = optional(number)              # Ordre (1 = premier, défaut auto)
    enabled  = optional(bool, true)          # Règle active

    # Options avancées
    quick        = optional(bool, true)      # Arrêter à la première correspondance
    gateway      = optional(string)          # Forcer un gateway (policy routing)
    state_type   = optional(string)          # keep state, sloppy state, etc.
  }))

  default = []

  validation {
    condition = alltrue([
      for rule in var.firewall_rules : contains(["pass", "block", "reject"], rule.action)
    ])
    error_message = "action doit être: pass, block, ou reject"
  }

  validation {
    condition = alltrue([
      for rule in var.firewall_rules : contains(["in", "out"], rule.direction)
    ])
    error_message = "direction doit être: in ou out"
  }
}

variable "enable_anti_lockout" {
  description = "Créer automatiquement une règle anti-lockout"
  type        = bool
  default     = true
}

variable "anti_lockout_interface" {
  description = "Interface pour la règle anti-lockout"
  type        = string
  default     = "lan"
}

variable "anti_lockout_port" {
  description = "Port pour la règle anti-lockout (accès admin)"
  type        = string
  default     = "443"
}

# -----------------------------------------------------------------------------
# Règle Anti-Lockout (OBLIGATOIRE)
# -----------------------------------------------------------------------------

resource "opnsense_firewall_filter" "anti_lockout" {
  count = var.enable_anti_lockout ? 1 : 0

  interface        = var.anti_lockout_interface
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "tcp"
  source_net       = "${var.anti_lockout_interface}net"
  destination_net  = "(self)"
  destination_port = var.anti_lockout_port
  description      = "ANTI-LOCKOUT: Accès admin depuis LAN"
  sequence         = 1
  enabled          = true
  quick            = true
  log              = false
}

# -----------------------------------------------------------------------------
# Règles de pare-feu
# -----------------------------------------------------------------------------

resource "opnsense_firewall_filter" "rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  interface   = each.value.interface
  direction   = each.value.direction
  ip_protocol = each.value.ip_protocol
  protocol    = each.value.protocol

  # Source
  source_net    = each.value.source_net
  source_port   = each.value.source_port
  source_invert = each.value.source_invert

  # Destination
  destination_net    = each.value.destination_net
  destination_port   = each.value.destination_port
  destination_invert = each.value.destination_invert

  # Action et options
  action      = each.value.action
  log         = each.value.log
  sequence    = each.value.sequence
  enabled     = each.value.enabled
  quick       = each.value.quick
  gateway     = each.value.gateway
  description = coalesce(each.value.description, each.value.name)

  depends_on = [opnsense_firewall_filter.anti_lockout]
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "firewall_rules" {
  description = "Règles de pare-feu créées"
  value = {
    for name, rule in opnsense_firewall_filter.rules : name => {
      id          = rule.id
      interface   = rule.interface
      action      = rule.action
      description = rule.description
      sequence    = rule.sequence
    }
  }
}

output "anti_lockout_rule" {
  description = "Règle anti-lockout"
  value = var.enable_anti_lockout ? {
    id          = opnsense_firewall_filter.anti_lockout[0].id
    interface   = opnsense_firewall_filter.anti_lockout[0].interface
    description = opnsense_firewall_filter.anti_lockout[0].description
  } : null
}

# -----------------------------------------------------------------------------
# Exemples d'utilisation
# -----------------------------------------------------------------------------
# firewall_rules = [
#   # Autoriser HTTP/HTTPS sortant depuis le LAN
#   {
#     name             = "lan_to_internet_web"
#     interface        = "lan"
#     direction        = "in"
#     action           = "pass"
#     protocol         = "tcp"
#     source_net       = "lannet"
#     destination_net  = "any"
#     destination_port = "80,443"
#     description      = "Autoriser HTTP/HTTPS sortant"
#   },
#
#   # Autoriser DNS sortant
#   {
#     name             = "lan_to_internet_dns"
#     interface        = "lan"
#     direction        = "in"
#     action           = "pass"
#     protocol         = "udp"
#     source_net       = "lannet"
#     destination_net  = "any"
#     destination_port = "53"
#     description      = "Autoriser DNS sortant"
#   },
#
#   # Bloquer tout le reste (deny by default)
#   {
#     name        = "lan_block_all"
#     interface   = "lan"
#     direction   = "in"
#     action      = "block"
#     protocol    = "any"
#     source_net  = "any"
#     destination_net = "any"
#     log         = true
#     sequence    = 65535
#     description = "Bloquer tout le reste"
#   }
# ]
# -----------------------------------------------------------------------------
