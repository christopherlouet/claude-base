# =============================================================================
# OPNsense Aliases Module
# =============================================================================
# Configures aliases (groups of addresses, networks, ports)
# Provider: browningluke/opnsense
# =============================================================================

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "aliases" {
  description = "List of aliases to create"
  type = list(object({
    name        = string                     # Unique alias name
    type        = string                     # Type: host, network, port, url, urltable
    description = optional(string)           # Description
    enabled     = optional(bool, true)

    # Content depending on type
    content = list(string)                   # List of IPs, networks, ports, URLs

    # Options for URL/URLTable
    refresh_frequency = optional(number)     # Refresh frequency (days)

    # Statistics
    counters = optional(bool, false)         # Enable pfTables counters
  }))

  default = []

  validation {
    condition = alltrue([
      for alias in var.aliases : contains(["host", "network", "port", "url", "urltable"], alias.type)
    ])
    error_message = "type must be: host, network, port, url, or urltable"
  }
}

# -----------------------------------------------------------------------------
# Standard Aliases (Host, Network, Port)
# -----------------------------------------------------------------------------

resource "opnsense_firewall_alias" "this" {
  for_each = { for alias in var.aliases : alias.name => alias }

  name        = each.value.name
  type        = each.value.type
  description = coalesce(each.value.description, "Alias: ${each.value.name}")
  enabled     = each.value.enabled

  # Content
  content = each.value.content

  # Advanced options
  counters = each.value.counters

  # Refresh for URL/URLTable
  refresh = each.value.refresh_frequency
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "aliases" {
  description = "Created aliases"
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
# Usage examples
# -----------------------------------------------------------------------------
# aliases = [
#   # Host-type alias (list of IPs)
#   {
#     name        = "SERVERS_WEB"
#     type        = "host"
#     description = "Internal web servers"
#     content     = ["192.168.10.20", "192.168.10.21"]
#   },
#
#   # Network-type alias (CIDR networks)
#   {
#     name        = "RFC1918"
#     type        = "network"
#     description = "RFC1918 private networks"
#     content     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
#   },
#
#   # Port-type alias
#   {
#     name        = "PORTS_WEB"
#     type        = "port"
#     description = "Web service ports"
#     content     = ["80", "443", "8080", "8443"]
#   },
#
#   # Port-type alias with ranges
#   {
#     name        = "PORTS_EPHEMERAL"
#     type        = "port"
#     description = "Ephemeral ports"
#     content     = ["1024:65535"]
#   },
#
#   # URL-type alias (external list)
#   {
#     name              = "BLOCKLIST_IPS"
#     type              = "urltable"
#     description       = "List of malicious IPs"
#     content           = ["https://www.spamhaus.org/drop/drop.txt"]
#     refresh_frequency = 1  # Refresh daily
#   },
#
#   # Alias for common services
#   {
#     name        = "DNS_PUBLIC"
#     type        = "host"
#     description = "Public DNS servers"
#     content     = ["1.1.1.1", "1.0.0.1", "8.8.8.8", "8.8.4.4"]
#   }
# ]
#
# # Usage in a firewall rule:
# # firewall_rules = [
# #   {
# #     name             = "web_to_servers"
# #     interface        = "lan"
# #     action           = "pass"
# #     protocol         = "tcp"
# #     source_net       = "lannet"
# #     destination_net  = "SERVERS_WEB"   # Uses the alias
# #     destination_port = "PORTS_WEB"     # Uses the alias
# #   }
# # ]
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Useful predefined aliases
# -----------------------------------------------------------------------------
# These aliases can be added to your configuration to simplify
# firewall rule management.
#
# RECOMMENDATION: Create at minimum these aliases:
#
# 1. TRUSTED_NETWORKS - Internal trusted networks
# 2. ADMIN_HOSTS - Administrators' machines
# 3. PORTS_ADMIN - Administration ports (22, 443, 3389)
# 4. SERVERS_DMZ - Exposed servers
# 5. BLOCKLIST_* - External blocklists
#
# This allows you to:
# - Change IPs/ports without touching the rules
# - Make the rules more readable
# - Facilitate security audits
# -----------------------------------------------------------------------------
