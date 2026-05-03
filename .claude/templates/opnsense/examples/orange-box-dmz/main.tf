# =============================================================================
# Complete example: OPNsense behind Orange Box in DMZ
# =============================================================================
# Architecture:
#   Internet → Orange Box (DMZ) → OPNsense → Local network
#
# Requirements:
#   1. OPNsense installed with API enabled
#   2. Orange Box configured in DMZ towards OPNsense
#   3. API credentials in environment variables
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

# WAN interface - Connected to the Orange Box (receives IP via DMZ)
resource "opnsense_interface" "wan" {
  device        = var.wan_device
  description   = "WAN - Orange Box"
  ipv4_type     = "dhcp"
  enabled       = true
  block_private = true
  block_bogons  = true
}

# LAN interface - Local network
resource "opnsense_interface" "lan" {
  device      = var.lan_device
  description = "LAN - Local network"
  ipv4_type   = "static"
  ipv4_addr   = var.lan_ip
  ipv4_mask   = var.lan_subnet
  enabled     = true
}

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# Web service ports
resource "opnsense_firewall_alias" "ports_web" {
  name        = "PORTS_WEB"
  type        = "port"
  content     = ["80", "443"]
  description = "HTTP/HTTPS ports"
}

# Admin ports
resource "opnsense_firewall_alias" "ports_admin" {
  name        = "PORTS_ADMIN"
  type        = "port"
  content     = ["22", "443"]
  description = "SSH and HTTPS admin ports"
}

# Public DNS
resource "opnsense_firewall_alias" "dns_public" {
  name        = "DNS_PUBLIC"
  type        = "host"
  content     = ["1.1.1.1", "1.0.0.1", "8.8.8.8", "8.8.4.4"]
  description = "Public DNS servers"
}

# -----------------------------------------------------------------------------
# Firewall Rules
# -----------------------------------------------------------------------------

# MANDATORY: Anti-lockout - Admin access from LAN
resource "opnsense_firewall_filter" "anti_lockout" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "(self)"
  destination_port = "443"
  description      = "ANTI-LOCKOUT: OPNsense admin access"
  sequence         = 1
  enabled          = true
  quick            = true
}

# Allow outbound HTTP/HTTPS from LAN
resource "opnsense_firewall_filter" "lan_to_web" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = opnsense_firewall_alias.ports_web.name
  description      = "Allow outbound HTTP/HTTPS"
  sequence         = 10
  enabled          = true
}

# Allow outbound DNS (UDP)
resource "opnsense_firewall_filter" "lan_to_dns_udp" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "udp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "53"
  description      = "Allow outbound DNS (UDP)"
  sequence         = 11
  enabled          = true
}

# Allow outbound DNS (TCP)
resource "opnsense_firewall_filter" "lan_to_dns_tcp" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "53"
  description      = "Allow outbound DNS (TCP)"
  sequence         = 12
  enabled          = true
}

# Allow outbound NTP
resource "opnsense_firewall_filter" "lan_to_ntp" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "udp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "123"
  description      = "Allow outbound NTP"
  sequence         = 13
  enabled          = true
}

# Allow outbound ICMP (ping)
resource "opnsense_firewall_filter" "lan_to_icmp" {
  interface   = "lan"
  direction   = "in"
  action      = "pass"
  ip_protocol = "inet"
  protocol    = "icmp"
  source_net  = "lannet"
  destination_net = "any"
  description = "Allow outbound ICMP (ping)"
  sequence    = 14
  enabled     = true
}

# Block and log everything else
resource "opnsense_firewall_filter" "lan_block_all" {
  interface       = "lan"
  direction       = "in"
  action          = "block"
  ip_protocol     = "inet"
  protocol        = "any"
  source_net      = "any"
  destination_net = "any"
  log             = true
  description     = "Block and log everything else"
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
# DHCP Reservations (example)
# -----------------------------------------------------------------------------

# Uncomment and adapt to your needs
# resource "opnsense_dhcp_v4_static_map" "server_example" {
#   interface   = "lan"
#   mac         = "00:11:22:33:44:55"
#   ipaddr      = "192.168.10.20"
#   hostname    = "server"
#   description = "Main server"
# }

# -----------------------------------------------------------------------------
# DNS (Unbound)
# -----------------------------------------------------------------------------

# Forwarder to Cloudflare
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
# NAT - Port Forwarding (commented examples)
# -----------------------------------------------------------------------------

# Uncomment and adapt to your needs

# HTTPS to web server
# resource "opnsense_nat_port_forward" "https_to_web" {
#   interface        = "wan"
#   protocol         = "tcp"
#   source_net       = "any"
#   source_port      = "443"
#   destination_net  = "wanip"
#   destination_port = "443"
#   target           = "192.168.10.20"
#   local_port       = "443"
#   description      = "HTTPS to web server"
#   nat_reflection   = "enable"
#   filter_rule_association = "add-associated"
# }

# SSH on non-standard port
# resource "opnsense_nat_port_forward" "ssh_to_server" {
#   interface        = "wan"
#   protocol         = "tcp"
#   source_net       = "any"
#   source_port      = "2222"
#   destination_net  = "wanip"
#   destination_port = "2222"
#   target           = "192.168.10.10"
#   local_port       = "22"
#   description      = "SSH to server (port 2222)"
# }
