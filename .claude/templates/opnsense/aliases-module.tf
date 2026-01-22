# =============================================================================
# Module Aliases OPNsense
# =============================================================================
# Configure les aliases (groupes d'adresses, réseaux, ports)
# Provider: browningluke/opnsense
# =============================================================================

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "aliases" {
  description = "Liste des aliases à créer"
  type = list(object({
    name        = string                     # Nom unique de l'alias
    type        = string                     # Type: host, network, port, url, urltable
    description = optional(string)           # Description
    enabled     = optional(bool, true)

    # Contenu selon le type
    content = list(string)                   # Liste d'IPs, réseaux, ports, URLs

    # Options pour URL/URLTable
    refresh_frequency = optional(number)     # Fréquence de rafraîchissement (jours)

    # Statistiques
    counters = optional(bool, false)         # Activer les compteurs pfTables
  }))

  default = []

  validation {
    condition = alltrue([
      for alias in var.aliases : contains(["host", "network", "port", "url", "urltable"], alias.type)
    ])
    error_message = "type doit être: host, network, port, url, ou urltable"
  }
}

# -----------------------------------------------------------------------------
# Alias Standards (Host, Network, Port)
# -----------------------------------------------------------------------------

resource "opnsense_firewall_alias" "this" {
  for_each = { for alias in var.aliases : alias.name => alias }

  name        = each.value.name
  type        = each.value.type
  description = coalesce(each.value.description, "Alias: ${each.value.name}")
  enabled     = each.value.enabled

  # Contenu
  content = each.value.content

  # Options avancées
  counters = each.value.counters

  # Refresh pour URL/URLTable
  refresh = each.value.refresh_frequency
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "aliases" {
  description = "Aliases créés"
  value = {
    for name, alias in opnsense_firewall_alias.this : name => {
      id          = alias.id
      name        = alias.name
      type        = alias.type
      content     = alias.content
      description = alias.description
    }
  }
}

# -----------------------------------------------------------------------------
# Exemples d'utilisation
# -----------------------------------------------------------------------------
# aliases = [
#   # Alias de type host (liste d'IPs)
#   {
#     name        = "SERVERS_WEB"
#     type        = "host"
#     description = "Serveurs web internes"
#     content     = ["192.168.10.20", "192.168.10.21"]
#   },
#
#   # Alias de type network (réseaux CIDR)
#   {
#     name        = "RFC1918"
#     type        = "network"
#     description = "Réseaux privés RFC1918"
#     content     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
#   },
#
#   # Alias de type port
#   {
#     name        = "PORTS_WEB"
#     type        = "port"
#     description = "Ports services web"
#     content     = ["80", "443", "8080", "8443"]
#   },
#
#   # Alias de type port avec plages
#   {
#     name        = "PORTS_EPHEMERAL"
#     type        = "port"
#     description = "Ports éphémères"
#     content     = ["1024:65535"]
#   },
#
#   # Alias de type URL (liste externe)
#   {
#     name              = "BLOCKLIST_IPS"
#     type              = "urltable"
#     description       = "Liste d'IPs malveillantes"
#     content           = ["https://www.spamhaus.org/drop/drop.txt"]
#     refresh_frequency = 1  # Rafraîchir tous les jours
#   },
#
#   # Alias pour services courants
#   {
#     name        = "DNS_PUBLIC"
#     type        = "host"
#     description = "Serveurs DNS publics"
#     content     = ["1.1.1.1", "1.0.0.1", "8.8.8.8", "8.8.4.4"]
#   }
# ]
#
# # Utilisation dans une règle firewall:
# # firewall_rules = [
# #   {
# #     name             = "web_to_servers"
# #     interface        = "lan"
# #     action           = "pass"
# #     protocol         = "tcp"
# #     source_net       = "lannet"
# #     destination_net  = "SERVERS_WEB"   # Utilise l'alias
# #     destination_port = "PORTS_WEB"     # Utilise l'alias
# #   }
# # ]
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Aliases prédéfinis utiles
# -----------------------------------------------------------------------------
# Ces aliases peuvent être ajoutés à votre configuration pour simplifier
# la gestion des règles firewall.
#
# RECOMMANDATION: Créer au minimum ces aliases:
#
# 1. TRUSTED_NETWORKS - Réseaux de confiance internes
# 2. ADMIN_HOSTS - Machines des administrateurs
# 3. PORTS_ADMIN - Ports d'administration (22, 443, 3389)
# 4. SERVERS_DMZ - Serveurs exposés
# 5. BLOCKLIST_* - Listes de blocage externes
#
# Cela permet de:
# - Modifier les IPs/ports sans toucher aux règles
# - Rendre les règles plus lisibles
# - Faciliter les audits de sécurité
# -----------------------------------------------------------------------------
