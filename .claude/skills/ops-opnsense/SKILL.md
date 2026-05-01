---
name: ops-opnsense
description: OPNsense configuration via Terraform. Trigger for interfaces, firewall, NAT, DHCP/DNS, aliases.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
argument-hint: "[component]"
---

# OPNsense Configuration (Terraform)

Complete guide to configure OPNsense declaratively with Terraform and the `browningluke/opnsense` provider.

## When to use this Skill

**Activate this skill to:**
- Configure OPNsense network interfaces (WAN, LAN, VLANs)
- Manage firewall rules
- Configure NAT and port forwarding
- Manage DHCP and DNS services
- Create aliases to simplify rules

**Do not use for:**
- Initial OPNsense installation (see manual documentation)
- VM provisioning (use `/ops:ops-proxmox`)
- Advanced OPNsense plugins (HAProxy, Suricata)

## Terraform Provider

| Attribute | Value |
|-----------|-------|
| **Provider** | `browningluke/opnsense` |
| **Version** | >= 0.11 |
| **Documentation** | https://registry.terraform.io/providers/browningluke/opnsense/latest/docs |
| **GitHub** | https://github.com/browningluke/terraform-provider-opnsense |

### Provider Configuration

```hcl
terraform {
  required_providers {
    opnsense = {
      source  = "browningluke/opnsense"
      version = "~> 0.11"
    }
  }
}

provider "opnsense" {
  uri                 = var.opnsense_uri        # https://192.168.10.1
  api_key             = var.opnsense_api_key    # Sensitive
  api_secret          = var.opnsense_api_secret # Sensitive
  allow_insecure = true                    # false in production
}
```

## Configuration Patterns

### 1. Network Interfaces

```hcl
# WAN interface (DHCP from ISP box)
resource "opnsense_interface" "wan" {
  device        = "vtnet0"
  description   = "WAN - Orange Box"
  ipv4_type     = "dhcp"
  block_private = true
  block_bogons  = true
}

# LAN interface (static IP)
resource "opnsense_interface" "lan" {
  device      = "vtnet1"
  description = "LAN - Local network"
  ipv4_type   = "static"
  ipv4_addr   = "192.168.10.1"
  ipv4_mask   = 24
}
```

### 2. Firewall Rules (CRITICAL: Anti-lockout)

```hcl
# MANDATORY: Anti-lockout rule (ALWAYS first)
resource "opnsense_firewall_filter" "anti_lockout" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "(self)"
  destination_port = "443"
  description      = "ANTI-LOCKOUT: Admin access"
  sequence         = 1
}

# Allow outbound HTTP/HTTPS
resource "opnsense_firewall_filter" "lan_to_web" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "80,443"
  description      = "Allow outbound HTTP/HTTPS"
  sequence         = 10
}

# Block everything else (deny by default)
resource "opnsense_firewall_filter" "lan_block_all" {
  interface   = "lan"
  direction   = "in"
  action      = "block"
  protocol    = "any"
  source_net  = "any"
  destination_net = "any"
  log         = true
  description = "Block and log everything else"
  sequence    = 65535
}
```

### 3. NAT / Port Forwarding

```hcl
# Port forward HTTPS to internal web server
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

# SSH on non-standard port
resource "opnsense_nat_port_forward" "ssh_to_server" {
  interface        = "wan"
  protocol         = "tcp"
  source_net       = "any"
  source_port      = "2222"
  destination_net  = "wanip"
  destination_port = "2222"
  target           = "192.168.10.10"
  local_port       = "22"
  description      = "SSH to server (port 2222)"
}
```

### 4. DHCP/DNS Services

```hcl
# DHCP server on LAN
resource "opnsense_dhcp_v4_server" "lan" {
  interface   = "lan"
  enabled     = true
  range_from  = "192.168.10.100"
  range_to    = "192.168.10.200"
  gateway     = "192.168.10.1"
  dns_servers = ["192.168.10.1"]
  domain      = "home.local"
  lease_time  = 86400
}

# DHCP reservation
resource "opnsense_dhcp_v4_static_map" "server_web" {
  interface   = "lan"
  mac         = "00:11:22:33:44:55"
  ipaddr      = "192.168.10.20"
  hostname    = "server-web"
  description = "Main web server"
}

# DNS forwarder
resource "opnsense_unbound_forward" "cloudflare" {
  enabled  = true
  host     = "1.1.1.1"
  port     = 53
  priority = 10
}

# Local DNS entry
resource "opnsense_unbound_host_override" "server_web" {
  enabled  = true
  hostname = "server"
  domain   = "home.local"
  server   = "192.168.10.20"
}
```

### 5. Aliases

```hcl
# Server alias
resource "opnsense_firewall_alias" "servers_web" {
  name        = "SERVERS_WEB"
  type        = "host"
  content     = ["192.168.10.20", "192.168.10.21"]
  description = "Internal web servers"
}

# Port alias
resource "opnsense_firewall_alias" "ports_web" {
  name        = "PORTS_WEB"
  type        = "port"
  content     = ["80", "443", "8080"]
  description = "Web service ports"
}

# Use in a rule
resource "opnsense_firewall_filter" "to_web_servers" {
  interface        = "lan"
  action           = "pass"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = opnsense_firewall_alias.servers_web.name
  destination_port = opnsense_firewall_alias.ports_web.name
  description      = "Access to web servers"
}
```

## Security

### Mandatory Rules

1. **Anti-lockout** (sequence = 1)
   - ALWAYS present
   - Allows admin access from LAN
   - Never delete

2. **Deny by default** (sequence = 65535)
   - Block anything not explicitly allowed
   - Log to detect attempts

3. **Secure credentials**
   - Environment variables or terraform.tfvars
   - NEVER in code
   - NEVER committed

### Best Practices

| Practice | Why |
|----------|-----|
| Use aliases | Readability and maintainability |
| Document each rule | Easier audit |
| Log block rules | Intrusion detection |
| Test in lab | Avoid lockouts |
| Backup before apply | Rollback possible |

## ISP Box + OPNsense Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Internet      │     │   Orange Box    │     │    OPNsense     │
│                 │────▶│   (192.168.1.1) │────▶│   WAN: DHCP     │
│                 │     │   DMZ Mode      │     │   LAN: .10.1    │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                           ┌─────────────┴─────────────┐
                                           │                           │
                                    ┌──────┴──────┐             ┌──────┴──────┐
                                    │  Server     │             │   Client    │
                                    │  .10.20     │             │   DHCP      │
                                    └─────────────┘             └─────────────┘
```

### Orange Box DMZ Configuration

1. Access the Livebox: `http://192.168.1.1`
2. Network > NAT/PAT > DMZ
3. Enable DMZ to OPNsense WAN IP
4. All ports are redirected to OPNsense

## WireGuard VPN (P3)

WireGuard VPN server configuration:

```hcl
# WireGuard interface
resource "opnsense_wireguard_server" "vpn" {
  name         = "wg0"
  enabled      = true
  listen_port  = 51820
  tunnel_addr  = "10.10.10.1/24"
  dns          = "192.168.10.1"
  private_key  = var.wireguard_private_key  # Sensitive
}

# Peer (VPN client)
resource "opnsense_wireguard_peer" "laptop" {
  server_id   = opnsense_wireguard_server.vpn.id
  name        = "laptop-chris"
  public_key  = "CLIENT_PUBLIC_KEY"
  allowed_ips = "10.10.10.2/32"
}

# Firewall rule for WireGuard
resource "opnsense_firewall_filter" "wireguard_in" {
  interface        = "wan"
  direction        = "in"
  action           = "pass"
  protocol         = "udp"
  destination_port = "51820"
  description      = "WireGuard VPN"
}
```

## Prometheus Monitoring (P3)

### node_exporter Installation

1. Install the `node_exporter` package via OPNsense
2. System > Services > node_exporter
3. Enable and configure the port (9100)

### Prometheus Configuration

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'opnsense'
    static_configs:
      - targets: ['192.168.10.1:9100']
    metrics_path: /metrics
```

### Useful Metrics

| Metric | Description |
|--------|-------------|
| `node_network_receive_bytes_total` | Inbound traffic |
| `node_network_transmit_bytes_total` | Outbound traffic |
| `node_cpu_seconds_total` | CPU usage |
| `node_memory_MemAvailable_bytes` | Available memory |
| `node_filesystem_avail_bytes` | Disk space |

## Troubleshooting

### API connection error

```bash
# Test the connection
curl -k -u "api-key:api-secret" \
  "https://192.168.10.1/api/core/firmware/status"

# Check:
# 1. API enabled (System > Settings > Administration)
# 2. API user with permissions
# 3. Firewall is not blocking
# 4. HTTPS certificate
```

### Lockout (lost access)

```bash
# Via Proxmox/local console
pfctl -d                    # Disable firewall
# Fix via web interface
pfctl -e                    # Re-enable firewall
```

### Terraform state out of sync

```bash
# Import existing resource
terraform import opnsense_firewall_filter.rule "uuid"

# Refresh
terraform refresh

# Force recreation
terraform taint opnsense_firewall_filter.rule
terraform apply
```

## Available Templates

Templates are in `.claude/templates/opnsense/`:

| Template | Description |
|----------|-------------|
| `provider-template.tf` | Provider configuration |
| `interfaces-module.tf` | WAN/LAN interfaces |
| `firewall-module.tf` | Firewall rules |
| `nat-module.tf` | NAT/port forward |
| `services-module.tf` | DHCP/DNS |
| `aliases-module.tf` | Address groups |
| `examples/orange-box-dmz/` | Complete example |

## Resources

- [OPNsense Documentation](https://docs.opnsense.org/)
- [Terraform Provider](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs)
- [OPNsense API](https://docs.opnsense.org/development/api.html)
- [WireGuard OPNsense](https://docs.opnsense.org/manual/how-tos/wireguard-client.html)
