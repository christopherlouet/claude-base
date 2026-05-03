---
sidebar_position: 5
title: OPNsense Firewall
description: Example OPNsense configuration with Terraform behind an Orange box
---

# OPNsense Firewall with Terraform

This example shows how to configure an OPNsense firewall as Infrastructure as Code with Terraform, in an architecture behind an Orange box in DMZ mode.

## Command used

```bash
/ops:ops-opnsense "Configure OPNsense behind Orange box with firewall, DHCP and DNS"
```

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Internet     │     │   Box Orange    │     │    OPNsense     │
│                 │────▶│  192.168.1.1    │────▶│   WAN: DHCP     │
│                 │     │   Mode DMZ      │     │   LAN: .10.1    │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                           ┌─────────────┴─────────────┐
                                           │       LAN 192.168.10.0/24 │
                                           │                           │
                                    ┌──────┴──────┐             ┌──────┴──────┐
                                    │  Serveurs   │             │  Clients    │
                                    │  .10.20+    │             │  DHCP       │
                                    └─────────────┘             └─────────────┘
```

## Generated structure

```
opnsense-config/
├── main.tf              # Main configuration
├── variables.tf         # Input variables
├── outputs.tf           # Outputs
└── terraform.tfvars     # Values (DO NOT COMMIT)
```

## Terraform code

### `providers.tf`

```hcl
terraform {
  required_version = "~> 1.9"

  required_providers {
    opnsense = {
      source  = "browningluke/opnsense"
      version = "~> 0.11"
    }
  }
}

provider "opnsense" {
  uri                 = var.opnsense_uri
  api_key             = var.opnsense_api_key
  api_secret          = var.opnsense_api_secret
  allow_insecure = var.allow_insecure
}
```

### `variables.tf`

```hcl
variable "opnsense_uri" {
  description = "OPNsense interface URL (e.g., https://192.168.10.1)"
  type        = string
}

variable "opnsense_api_key" {
  description = "OPNsense API key"
  type        = string
  sensitive   = true
}

variable "opnsense_api_secret" {
  description = "OPNsense API secret"
  type        = string
  sensitive   = true
}

variable "allow_insecure" {
  description = "Allow self-signed certificates"
  type        = bool
  default     = true
}

variable "lan_ip" {
  description = "OPNsense LAN IP address"
  type        = string
  default     = "192.168.10.1"
}

variable "dhcp_range_start" {
  description = "First IP of the DHCP range"
  type        = string
  default     = "192.168.10.100"
}

variable "dhcp_range_end" {
  description = "Last IP of the DHCP range"
  type        = string
  default     = "192.168.10.200"
}
```

### `main.tf`

```hcl
# =============================================================================
# Interfaces
# =============================================================================

# WAN interface - Connected to the Orange box (gets IP via DMZ)
resource "opnsense_interface" "wan" {
  device        = "vtnet0"
  description   = "WAN - Box Orange"
  ipv4_type     = "dhcp"
  enabled       = true
  block_private = true
  block_bogons  = true
}

# LAN interface - Local network
resource "opnsense_interface" "lan" {
  device      = "vtnet1"
  description = "LAN - Local network"
  ipv4_type   = "static"
  ipv4_addr   = var.lan_ip
  ipv4_mask   = 24
  enabled     = true
}

# =============================================================================
# Aliases
# =============================================================================

resource "opnsense_firewall_alias" "ports_web" {
  name        = "PORTS_WEB"
  type        = "port"
  content     = ["80", "443"]
  description = "HTTP/HTTPS ports"
}

resource "opnsense_firewall_alias" "dns_public" {
  name        = "DNS_PUBLIC"
  type        = "host"
  content     = ["1.1.1.1", "1.0.0.1", "8.8.8.8", "8.8.4.4"]
  description = "Public DNS servers"
}

# =============================================================================
# Firewall rules
# =============================================================================

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

# =============================================================================
# DHCP Server
# =============================================================================

resource "opnsense_dhcp_v4_server" "lan" {
  interface   = "lan"
  enabled     = true
  range_from  = var.dhcp_range_start
  range_to    = var.dhcp_range_end
  gateway     = var.lan_ip
  dns_servers = [var.lan_ip]
  domain      = "home.local"
  lease_time  = 86400
}

# =============================================================================
# DNS (Unbound Forwarders)
# =============================================================================

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
```

### `outputs.tf`

```hcl
output "lan_network" {
  description = "Configured LAN network"
  value       = "${opnsense_interface.lan.ipv4_addr}/${opnsense_interface.lan.ipv4_mask}"
}

output "dhcp_range" {
  description = "DHCP range"
  value       = "${opnsense_dhcp_v4_server.lan.range_from} - ${opnsense_dhcp_v4_server.lan.range_to}"
}

output "admin_url" {
  description = "OPNsense admin URL"
  value       = "https://${opnsense_interface.lan.ipv4_addr}"
}

output "summary" {
  description = "Configuration summary"
  value = <<-EOT
    ╔═══════════════════════════════════════════════════════════════╗
    ║           OPNsense - Orange Box Configuration                  ║
    ╠═══════════════════════════════════════════════════════════════╣
    ║  WAN: ${opnsense_interface.wan.device} (DHCP from Orange Box)
    ║  LAN: ${opnsense_interface.lan.device} (${opnsense_interface.lan.ipv4_addr}/${opnsense_interface.lan.ipv4_mask})
    ║
    ║  DHCP: ${opnsense_dhcp_v4_server.lan.range_from} - ${opnsense_dhcp_v4_server.lan.range_to}
    ║  DNS: Cloudflare (1.1.1.1, 1.0.0.1)
    ║
    ║  Firewall: 4 rules (anti-lockout + web + dns + block)
    ╚═══════════════════════════════════════════════════════════════╝

    Admin access: https://${opnsense_interface.lan.ipv4_addr}
  EOT
}
```

## Deployment

### 1. Configure credentials

```bash
# Environment variables (recommended)
export TF_VAR_opnsense_uri="https://192.168.10.1"
export TF_VAR_opnsense_api_key="your-api-key"
export TF_VAR_opnsense_api_secret="your-api-secret"
```

### 2. Initialize and apply

```bash
terraform init
terraform plan
terraform apply
```

### 3. Verify

```bash
terraform output summary
```

## Customization

### Add a DHCP reservation

```hcl
resource "opnsense_dhcp_v4_static_map" "server" {
  interface   = "lan"
  mac         = "00:11:22:33:44:55"
  ipaddr      = "192.168.10.20"
  hostname    = "server"
  description = "Main server"
}
```

### Add a port forwarding

```hcl
resource "opnsense_nat_port_forward" "https_to_web" {
  interface        = "wan"
  protocol         = "tcp"
  source_net       = "any"
  source_port      = "443"
  destination_net  = "wanip"
  destination_port = "443"
  target           = "192.168.10.20"
  local_port       = "443"
  description      = "HTTPS to web server"
  nat_reflection   = "enable"
  filter_rule_association = "add-associated"
}
```

## Security points

:::danger Anti-lockout rule
The anti-lockout rule (sequence 1) is **CRITICAL**. Never delete it or you will lose admin access.
:::

:::warning Credentials
- Never commit `terraform.tfvars` with credentials
- Use environment variables in CI/CD
- Add `*.tfstate*` and `terraform.tfvars` to `.gitignore`
:::

## Troubleshooting

### API connection error

```bash
curl -k -u "$TF_VAR_opnsense_api_key:$TF_VAR_opnsense_api_secret" \
  "$TF_VAR_opnsense_uri/api/core/firmware/status"
```

### Lockout (access lost)

Via Proxmox/local console:
```bash
pfctl -d          # Disable the firewall
# Fix via web interface
pfctl -e          # Re-enable the firewall
```

## See also

- [Command `/ops:ops-opnsense`](/docs/commands/ops/ops-opnsense)
- [Skill `ops-opnsense`](/docs/skills/ops-opnsense)
- [Agent `ops-opnsense`](/docs/agents/ops-opnsense)
- [Proxmox VM example](/docs/examples/ops/proxmox-vm)
