---
sidebar_position: 10
title: "09 - OPNsense Firewall"
description: Configure OPNsense as a firewall behind an ISP router with Terraform
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# OPNsense Firewall with Terraform

<DifficultyBadge level="intermediate" /> **Estimated duration: 45 minutes**

This tutorial shows you how to configure an OPNsense firewall as Infrastructure as Code with Terraform, in an architecture behind an ISP router (Orange, Free, SFR, etc.) in DMZ mode.

## Objectives

By the end of this tutorial, you will know how to:
- Use `/ops:ops-opnsense` to manage OPNsense via Terraform
- Configure WAN/LAN interfaces
- Create secure firewall rules
- Configure DHCP and DNS
- Manage aliases and NAT

## Prerequisites

- OPNsense installed (Proxmox VM or physical machine)
- 2 network interfaces (WAN + LAN)
- OPNsense API enabled with API keys
- Terraform installed locally
- ISP router configured in DMZ mode

## Target architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Internet     │     │   ISP Router    │     │    OPNsense     │
│                 │────▶│  192.168.1.1    │────▶│   WAN: DHCP     │
│                 │     │   DMZ Mode      │     │   LAN: .10.1    │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                           ┌─────────────┴─────────────┐
                                           │       LAN 192.168.10.0/24 │
                                           │                           │
                                    ┌──────┴──────┐             ┌──────┴──────┐
                                    │   Servers   │             │   Clients   │
                                    │  .10.20+    │             │   DHCP      │
                                    └─────────────┘             └─────────────┘
```

## Step 1: Prepare OPNsense

### Enable the API

1. Log in to OPNsense: `https://192.168.10.1`
2. **System > Settings > Administration**
3. Enable **Enable API**
4. Save

### Create an API user

1. **System > Access > Users**
2. Create a new user (e.g., `terraform-api`)
3. In the **API Keys** tab, generate a key
4. **NOTE** the key and the secret (displayed only once)

### Configure the router in DMZ

1. Access the router: `http://192.168.1.1`
2. **Network > NAT/PAT > DMZ** (or equivalent depending on the ISP)
3. Enable the DMZ towards the OPNsense WAN IP (e.g., 192.168.1.50)
4. All ports will be redirected to OPNsense

## Step 2: Initialize the Terraform project

```bash
/ops:ops-opnsense "Create the project structure to configure OPNsense"
```

### File structure

```
opnsense-infra/
├── main.tf              # Main configuration
├── variables.tf         # Input variables
├── outputs.tf           # Outputs
├── terraform.tfvars     # Values (DO NOT COMMIT)
└── .gitignore
```

### Provider configuration

**`providers.tf`**
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
  allow_insecure = true  # false in production with a valid certificate
}
```

### Variables

**`variables.tf`**
```hcl
# Provider
variable "opnsense_uri" {
  description = "OPNsense interface URL"
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

# Network
variable "lan_ip" {
  description = "OPNsense LAN IP address"
  type        = string
  default     = "192.168.10.1"
}

variable "lan_subnet" {
  description = "LAN subnet mask"
  type        = number
  default     = 24
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

variable "local_domain" {
  description = "Local domain"
  type        = string
  default     = "home.local"
}
```

### Credentials

```bash
# Option 1: Environment variables (recommended)
export TF_VAR_opnsense_uri="https://192.168.10.1"
export TF_VAR_opnsense_api_key="your-api-key"
export TF_VAR_opnsense_api_secret="your-api-secret"

# Option 2: terraform.tfvars file (DO NOT COMMIT)
cat > terraform.tfvars << 'EOF'
opnsense_uri        = "https://192.168.10.1"
opnsense_api_key    = "your-api-key"
opnsense_api_secret = "your-api-secret"
EOF
```

## Step 3: Configure the interfaces

```bash
/ops:ops-opnsense "Configure WAN (DHCP) and LAN (static) interfaces"
```

**`main.tf`** - Interfaces section
```hcl
# =============================================================================
# Interfaces
# =============================================================================

# WAN interface - Connected to the ISP router (receives IP via DMZ)
resource "opnsense_interface" "wan" {
  device        = "vtnet0"    # Adapt to your hardware
  description   = "WAN - ISP Router"
  ipv4_type     = "dhcp"
  enabled       = true
  block_private = true        # Block RFC1918 on WAN
  block_bogons  = true        # Block invalid addresses
}

# LAN interface - Local network
resource "opnsense_interface" "lan" {
  device      = "vtnet1"      # Adapt to your hardware
  description = "LAN - Local network"
  ipv4_type   = "static"
  ipv4_addr   = var.lan_ip
  ipv4_mask   = var.lan_subnet
  enabled     = true
}
```

:::tip Identify the interfaces
To find out the names of your interfaces:
- Via OPNsense: **Interfaces > Assignments**
- Via console: `ifconfig -a`
- Common names: `vtnet0/vtnet1` (virtIO), `em0/em1` (Intel), `igb0/igb1` (Intel Gigabit)
:::

## Step 4: Create the aliases

Aliases let you group IP addresses or ports to simplify rules.

```bash
/ops:ops-opnsense "Create aliases for web ports and public DNS"
```

**`main.tf`** - Aliases section
```hcl
# =============================================================================
# Aliases
# =============================================================================

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
  description = "SSH and admin HTTPS ports"
}

# Public DNS
resource "opnsense_firewall_alias" "dns_public" {
  name        = "DNS_PUBLIC"
  type        = "host"
  content     = ["1.1.1.1", "1.0.0.1", "8.8.8.8", "8.8.4.4"]
  description = "Public DNS servers (Cloudflare + Google)"
}
```

## Step 5: Configure the firewall

:::danger MANDATORY Anti-lockout rule
The anti-lockout rule must **ALWAYS** be at sequence 1. Without it, you will lose access to OPNsense after applying the rules.
:::

```bash
/ops:ops-opnsense "Create firewall rules with anti-lockout"
```

**`main.tf`** - Firewall section
```hcl
# =============================================================================
# Firewall Rules
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
  sequence         = 1           # ALWAYS first
  enabled          = true
  quick            = true
}

# Allow outgoing HTTP/HTTPS from the LAN
resource "opnsense_firewall_filter" "lan_to_web" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = opnsense_firewall_alias.ports_web.name
  description      = "Allow outgoing HTTP/HTTPS"
  sequence         = 10
  enabled          = true
}

# Allow outgoing DNS (UDP)
resource "opnsense_firewall_filter" "lan_to_dns_udp" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "udp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "53"
  description      = "Allow outgoing DNS (UDP)"
  sequence         = 11
  enabled          = true
}

# Allow outgoing DNS (TCP - for DNSSEC)
resource "opnsense_firewall_filter" "lan_to_dns_tcp" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "53"
  description      = "Allow outgoing DNS (TCP)"
  sequence         = 12
  enabled          = true
}

# Allow outgoing NTP
resource "opnsense_firewall_filter" "lan_to_ntp" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  ip_protocol      = "inet"
  protocol         = "udp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "123"
  description      = "Allow outgoing NTP"
  sequence         = 13
  enabled          = true
}

# Allow outgoing ICMP (ping)
resource "opnsense_firewall_filter" "lan_to_icmp" {
  interface       = "lan"
  direction       = "in"
  action          = "pass"
  ip_protocol     = "inet"
  protocol        = "icmp"
  source_net      = "lannet"
  destination_net = "any"
  description     = "Allow outgoing ICMP (ping)"
  sequence        = 14
  enabled         = true
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
  sequence        = 65535        # Always last
  enabled         = true
}
```

## Step 6: Configure DHCP and DNS

```bash
/ops:ops-opnsense "Configure the DHCP server and DNS forwarders"
```

**`main.tf`** - Services section
```hcl
# =============================================================================
# DHCP Server
# =============================================================================

resource "opnsense_dhcp_v4_server" "lan" {
  interface   = "lan"
  enabled     = true
  range_from  = var.dhcp_range_start
  range_to    = var.dhcp_range_end
  gateway     = var.lan_ip
  dns_servers = [var.lan_ip]          # OPNsense as DNS
  domain      = var.local_domain
  lease_time  = 86400                  # 24 hours
}

# =============================================================================
# DNS (Unbound Forwarders)
# =============================================================================

# Forwarder to Cloudflare (primary)
resource "opnsense_unbound_forward" "cloudflare_1" {
  enabled  = true
  host     = "1.1.1.1"
  port     = 53
  priority = 10
}

# Forwarder to Cloudflare (secondary)
resource "opnsense_unbound_forward" "cloudflare_2" {
  enabled  = true
  host     = "1.0.0.1"
  port     = 53
  priority = 20
}
```

## Step 7: Deploy

### Initialize Terraform

```bash
terraform init
```

### Preview the changes

```bash
terraform plan
```

### Apply the configuration

```bash
terraform apply
```

### Verify

```bash
terraform output summary
```

## Step 8: Customization (optional)

### Add a DHCP reservation

```hcl
resource "opnsense_dhcp_v4_static_map" "server_web" {
  interface   = "lan"
  mac         = "00:11:22:33:44:55"
  ipaddr      = "192.168.10.20"
  hostname    = "server-web"
  description = "Main web server"
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

### Add a local DNS entry

```hcl
resource "opnsense_unbound_host_override" "server_web" {
  enabled  = true
  hostname = "server"
  domain   = "home.local"
  server   = "192.168.10.20"
}
```

## Troubleshooting

### API connection error

```bash
# Test the connection
curl -k -u "$TF_VAR_opnsense_api_key:$TF_VAR_opnsense_api_secret" \
  "$TF_VAR_opnsense_uri/api/core/firmware/status"
```

**Check**:
1. API enabled in OPNsense
2. API user with permissions
3. Firewall is not blocking
4. Valid HTTPS certificate or `allow_insecure = true`

### Lockout (access lost)

Via Proxmox console or physical access:
```bash
# Temporarily disable the firewall
pfctl -d

# Fix via web interface
# ...

# Re-enable the firewall
pfctl -e
```

### State out of sync

```bash
# Refresh the state
terraform refresh

# Import an existing resource
terraform import opnsense_firewall_filter.rule "uuid-of-the-rule"

# Force recreation
terraform taint opnsense_firewall_filter.rule
terraform apply
```

## Best practices

| Practice | Why |
|----------|----------|
| **Anti-lockout at sequence 1** | Avoid losing access |
| **Use aliases** | Readability and maintainability |
| **Document each rule** | Easier auditing |
| **Log block rules** | Intrusion detection |
| **Test in a lab** | Avoid lockouts |
| **Backup before apply** | Rollback possible |
| **Never commit credentials** | Security |

## Summary

You have learned how to:
- ✅ Configure OPNsense with Terraform
- ✅ Create WAN/LAN interfaces
- ✅ Manage aliases
- ✅ Create secure firewall rules
- ✅ Configure DHCP and DNS
- ✅ Customize with reservations and port forwarding

## Commands used

| Command | Usage |
|----------|-------|
| `/ops:ops-opnsense` | Full OPNsense configuration |
| `/ops:ops-infra-code` | Generic Infrastructure as Code |

## See also

- [Command `/ops:ops-opnsense`](/docs/commands/ops/ops-opnsense)
- [Skill `ops-opnsense`](/docs/skills/ops-opnsense)
- [OPNsense example](/docs/examples/ops/opnsense-config)
- [Proxmox tutorial](/docs/tutorials/proxmox-infra)
