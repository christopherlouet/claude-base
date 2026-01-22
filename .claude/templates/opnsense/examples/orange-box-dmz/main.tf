# =============================================================================
# Exemple complet: OPNsense derrière Box Orange en DMZ
# =============================================================================
# Architecture:
#   Internet → Box Orange (DMZ) → OPNsense → Réseau local
#
# Prérequis:
#   1. OPNsense installé avec API activée
#   2. Box Orange configurée en DMZ vers OPNsense
#   3. Credentials API dans variables d'environnement
# =============================================================================

terraform {
  required_version = "~> 1.9"

  required_providers {
    opnsense = {
      source  = "browningluke/opnsense"
      version = "~> 0.11"
    }
  }
}

# -----------------------------------------------------------------------------
# Provider
# -----------------------------------------------------------------------------

provider "opnsense" {
  uri            = var.opnsense_uri
  api_key        = var.opnsense_api_key
  api_secret     = var.opnsense_api_secret
  allow_insecure = var.allow_insecure
}

# -----------------------------------------------------------------------------
# Interfaces
# -----------------------------------------------------------------------------

# Interface WAN - Connectée à la Box Orange (reçoit IP via DMZ)
resource "opnsense_interface" "wan" {
  device        = var.wan_device
  description   = "WAN - Box Orange"
  ipv4_type     = "dhcp"
  enabled       = true
  block_private = true
  block_bogons  = true
}

# Interface LAN - Réseau local
resource "opnsense_interface" "lan" {
  device      = var.lan_device
  description = "LAN - Réseau local"
  ipv4_type   = "static"
  ipv4_addr   = var.lan_ip
  ipv4_mask   = var.lan_subnet
  enabled     = true
}

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# Ports services web
resource "opnsense_firewall_alias" "ports_web" {
  name        = "PORTS_WEB"
  type        = "port"
  content     = ["80", "443"]
  description = "Ports HTTP/HTTPS"
}

# Ports pour administration
resource "opnsense_firewall_alias" "ports_admin" {
  name        = "PORTS_ADMIN"
  type        = "port"
  content     = ["22", "443"]
  description = "Ports SSH et HTTPS admin"
}

# DNS publics
resource "opnsense_firewall_alias" "dns_public" {
  name        = "DNS_PUBLIC"
  type        = "host"
  content     = ["1.1.1.1", "1.0.0.1", "8.8.8.8", "8.8.4.4"]
  description = "Serveurs DNS publics"
}

# -----------------------------------------------------------------------------
# Règles Firewall
# -----------------------------------------------------------------------------

# OBLIGATOIRE: Anti-lockout - Accès admin depuis LAN
resource "opnsense_firewall_filter" "anti_lockout" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "(self)"
  destination_port = "443"
  description      = "ANTI-LOCKOUT: Accès admin OPNsense"
  sequence         = 1
  enabled          = true
  quick            = true
}

# Autoriser HTTP/HTTPS sortant depuis le LAN
resource "opnsense_firewall_filter" "lan_to_web" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = opnsense_firewall_alias.ports_web.name
  description      = "Autoriser HTTP/HTTPS sortant"
  sequence         = 10
  enabled          = true
}

# Autoriser DNS sortant (UDP)
resource "opnsense_firewall_filter" "lan_to_dns_udp" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "udp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "53"
  description      = "Autoriser DNS sortant (UDP)"
  sequence         = 11
  enabled          = true
}

# Autoriser DNS sortant (TCP)
resource "opnsense_firewall_filter" "lan_to_dns_tcp" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "53"
  description      = "Autoriser DNS sortant (TCP)"
  sequence         = 12
  enabled          = true
}

# Autoriser NTP sortant
resource "opnsense_firewall_filter" "lan_to_ntp" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "udp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "123"
  description      = "Autoriser NTP sortant"
  sequence         = 13
  enabled          = true
}

# Autoriser ICMP (ping) sortant
resource "opnsense_firewall_filter" "lan_to_icmp" {
  interface   = "lan"
  direction   = "in"
  action      = "pass"
  ip_protocol = "inet"
  protocol    = "icmp"
  source_net  = "lannet"
  destination_net = "any"
  description = "Autoriser ICMP (ping) sortant"
  sequence    = 14
  enabled     = true
}

# Bloquer et logger tout le reste
resource "opnsense_firewall_filter" "lan_block_all" {
  interface       = "lan"
  direction       = "in"
  action          = "block"
  ip_protocol     = "inet"
  protocol        = "any"
  source_net      = "any"
  destination_net = "any"
  log             = true
  description     = "Bloquer et logger tout le reste"
  sequence        = 65535
  enabled         = true
}

# -----------------------------------------------------------------------------
# DHCP Server
# -----------------------------------------------------------------------------

resource "opnsense_dhcp_v4_server" "lan" {
  interface   = "lan"
  enabled     = true
  range_from  = var.dhcp_range_start
  range_to    = var.dhcp_range_end
  gateway     = var.lan_ip
  dns_servers = [var.lan_ip]
  domain      = var.local_domain
  lease_time  = 86400
}

# -----------------------------------------------------------------------------
# Réservations DHCP (exemple)
# -----------------------------------------------------------------------------

# Décommenter et adapter selon vos besoins
# resource "opnsense_dhcp_v4_static_map" "server_example" {
#   interface   = "lan"
#   mac         = "00:11:22:33:44:55"
#   ipaddr      = "192.168.10.20"
#   hostname    = "server"
#   description = "Serveur principal"
# }

# -----------------------------------------------------------------------------
# DNS (Unbound)
# -----------------------------------------------------------------------------

# Forwarder vers Cloudflare
resource "opnsense_unbound_forward" "cloudflare_1" {
  enabled  = true
  host     = "1.1.1.1"
  port     = 53
  priority = 10
}

resource "opnsense_unbound_forward" "cloudflare_2" {
  enabled  = true
  host     = "1.0.0.1"
  port     = 53
  priority = 20
}

# -----------------------------------------------------------------------------
# NAT - Port Forwarding (exemples commentés)
# -----------------------------------------------------------------------------

# Décommenter et adapter selon vos besoins

# HTTPS vers serveur web
# resource "opnsense_nat_port_forward" "https_to_web" {
#   interface        = "wan"
#   protocol         = "tcp"
#   source_net       = "any"
#   source_port      = "443"
#   destination_net  = "wanip"
#   destination_port = "443"
#   target           = "192.168.10.20"
#   local_port       = "443"
#   description      = "HTTPS vers serveur web"
#   nat_reflection   = "enable"
#   filter_rule_association = "add-associated"
# }

# SSH sur port non-standard
# resource "opnsense_nat_port_forward" "ssh_to_server" {
#   interface        = "wan"
#   protocol         = "tcp"
#   source_net       = "any"
#   source_port      = "2222"
#   destination_net  = "wanip"
#   destination_port = "2222"
#   target           = "192.168.10.10"
#   local_port       = "22"
#   description      = "SSH vers serveur (port 2222)"
# }
