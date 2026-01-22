# =============================================================================
# Outputs - OPNsense derrière Box Orange
# =============================================================================

# -----------------------------------------------------------------------------
# Interfaces
# -----------------------------------------------------------------------------

output "wan_interface" {
  description = "Interface WAN configurée"
  value = {
    id          = opnsense_interface.wan.id
    device      = opnsense_interface.wan.device
    description = opnsense_interface.wan.description
    type        = opnsense_interface.wan.ipv4_type
  }
}

output "lan_interface" {
  description = "Interface LAN configurée"
  value = {
    id        = opnsense_interface.lan.id
    device    = opnsense_interface.lan.device
    ip        = opnsense_interface.lan.ipv4_addr
    mask      = opnsense_interface.lan.ipv4_mask
    network   = "${opnsense_interface.lan.ipv4_addr}/${opnsense_interface.lan.ipv4_mask}"
  }
}

# -----------------------------------------------------------------------------
# DHCP
# -----------------------------------------------------------------------------

output "dhcp_server" {
  description = "Serveur DHCP configuré"
  value = {
    id         = opnsense_dhcp_v4_server.lan.id
    interface  = opnsense_dhcp_v4_server.lan.interface
    range      = "${opnsense_dhcp_v4_server.lan.range_from} - ${opnsense_dhcp_v4_server.lan.range_to}"
    gateway    = opnsense_dhcp_v4_server.lan.gateway
    domain     = opnsense_dhcp_v4_server.lan.domain
  }
}

# -----------------------------------------------------------------------------
# Firewall
# -----------------------------------------------------------------------------

output "firewall_rules_count" {
  description = "Nombre de règles firewall créées"
  value       = 7  # anti_lockout + web + dns_udp + dns_tcp + ntp + icmp + block_all
}

output "anti_lockout_rule" {
  description = "Règle anti-lockout (CRITIQUE)"
  value = {
    id          = opnsense_firewall_filter.anti_lockout.id
    interface   = opnsense_firewall_filter.anti_lockout.interface
    port        = opnsense_firewall_filter.anti_lockout.destination_port
    description = opnsense_firewall_filter.anti_lockout.description
  }
}

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

output "aliases" {
  description = "Aliases créés"
  value = {
    ports_web   = opnsense_firewall_alias.ports_web.name
    ports_admin = opnsense_firewall_alias.ports_admin.name
    dns_public  = opnsense_firewall_alias.dns_public.name
  }
}

# -----------------------------------------------------------------------------
# DNS
# -----------------------------------------------------------------------------

output "dns_forwarders" {
  description = "Forwarders DNS configurés"
  value = [
    opnsense_unbound_forward.cloudflare_1.host,
    opnsense_unbound_forward.cloudflare_2.host
  ]
}

# -----------------------------------------------------------------------------
# Résumé
# -----------------------------------------------------------------------------

output "summary" {
  description = "Résumé de la configuration"
  value = <<-EOT
    ╔═══════════════════════════════════════════════════════════════╗
    ║           OPNsense - Configuration Box Orange                  ║
    ╠═══════════════════════════════════════════════════════════════╣
    ║  WAN: ${opnsense_interface.wan.device} (DHCP depuis Box Orange)
    ║  LAN: ${opnsense_interface.lan.device} (${opnsense_interface.lan.ipv4_addr}/${opnsense_interface.lan.ipv4_mask})
    ║
    ║  DHCP: ${opnsense_dhcp_v4_server.lan.range_from} - ${opnsense_dhcp_v4_server.lan.range_to}
    ║  DNS: Cloudflare (1.1.1.1, 1.0.0.1)
    ║  Domaine: ${opnsense_dhcp_v4_server.lan.domain}
    ║
    ║  Firewall: 7 règles (anti-lockout + web + dns + ntp + icmp)
    ╚═══════════════════════════════════════════════════════════════╝

    Accès admin: https://${opnsense_interface.lan.ipv4_addr}
  EOT
}
