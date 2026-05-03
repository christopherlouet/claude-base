# OPNsense Templates - Infrastructure as Code

Terraform templates to manage OPNsense declaratively.

## Table of contents

- [Prerequisites](#prerequisites)
- [Structure](#structure)
- [Initial configuration](#initial-configuration)
- [Available modules](#available-modules)
- [Complete example](#complete-example)
- [Security](#security)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### OPNsense

- **Version**: 24.1 or higher
- **API enabled**: System > Settings > Administration > Enable API
- **API user**: System > Access > Users > Create user with API keys

### Terraform

- **Version**: 1.9+
- **Provider**: `browningluke/opnsense` >= 0.11

### Network

- OPNsense reachable from the Terraform machine
- Ports 443 (HTTPS) and 80 (HTTP if non-SSL)

## Structure

```
.claude/templates/opnsense/
├── README.md                 # This file
├── provider-template.tf      # Provider configuration
├── interfaces-module.tf      # WAN/LAN interfaces module
├── firewall-module.tf        # Firewall rules module
├── nat-module.tf             # NAT/port forward module
├── services-module.tf        # DHCP/DNS module
├── aliases-module.tf         # Address groups module
└── examples/
    └── orange-box-dmz/       # Complete Orange Box example
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## Initial configuration

### 1. Create an OPNsense VM template (Proxmox)

```bash
# Download the OPNsense ISO
wget https://mirror.ams1.nl.leaseweb.net/opnsense/releases/24.1/OPNsense-24.1-dvd-amd64.iso

# Create VM in Proxmox
# - CPU: 2 cores
# - RAM: 4 GB
# - Disk: 32 GB
# - Network: 2 interfaces (WAN + LAN)

# Install OPNsense manually
# Convert to template after base configuration
```

### 2. Enable the OPNsense API

1. Log in to the web interface: `https://<IP-OPNsense>`
2. Go to **System > Settings > Administration**
3. Check **Enable API**
4. Save

### 3. Create an API user

1. **System > Access > Users**
2. Click **+** to add a user
3. Name: `terraform`
4. Check **Generate scrambled password**
5. In the **API keys** section, click **+**
6. Download the keys (`.txt` file)
7. Assign permissions:
   - `GUI All pages` (for full access)
   - Or granular permissions as needed

### 4. Configure credentials

```bash
# Recommended method: environment variables
export TF_VAR_opnsense_uri="https://192.168.10.1"
export TF_VAR_opnsense_api_key="your-api-key"
export TF_VAR_opnsense_api_secret="your-api-secret"

# Alternative: terraform.tfvars (DO NOT COMMIT)
# Add terraform.tfvars to .gitignore
```

## Available modules

### interfaces-module.tf

Configures network interfaces (WAN, LAN, VLANs).

```hcl
module "interfaces" {
  source = "./.claude/templates/opnsense"

  wan_interface = "vtnet0"
  wan_type      = "dhcp"  # or "static"

  lan_interface = "vtnet1"
  lan_ip        = "192.168.10.1"
  lan_subnet    = 24
}
```

### firewall-module.tf

Manages firewall rules.

```hcl
module "firewall" {
  source = "./.claude/templates/opnsense"

  rules = [
    {
      interface   = "lan"
      direction   = "in"
      action      = "pass"
      protocol    = "tcp"
      source      = "lan"
      destination = "any"
      port        = "80,443"
      description = "Allow outbound HTTP/HTTPS"
    }
  ]
}
```

### nat-module.tf

Configures outbound NAT and port forwarding.

```hcl
module "nat" {
  source = "./.claude/templates/opnsense"

  port_forwards = [
    {
      interface     = "wan"
      protocol      = "tcp"
      external_port = "443"
      target_ip     = "192.168.10.20"
      target_port   = "443"
      description   = "HTTPS to web server"
    }
  ]
}
```

### services-module.tf

Configures DHCP and DNS.

```hcl
module "services" {
  source = "./.claude/templates/opnsense"

  dhcp_interface   = "lan"
  dhcp_range_start = "192.168.10.100"
  dhcp_range_end   = "192.168.10.200"
  dhcp_gateway     = "192.168.10.1"
  dhcp_dns         = ["192.168.10.1"]

  dhcp_reservations = [
    {
      mac  = "00:11:22:33:44:55"
      ip   = "192.168.10.10"
      name = "server-web"
    }
  ]
}
```

### aliases-module.tf

Creates address groups to simplify rules.

```hcl
module "aliases" {
  source = "./.claude/templates/opnsense"

  aliases = [
    {
      name    = "SERVERS_WEB"
      type    = "host"
      content = ["192.168.10.20", "192.168.10.21"]
    },
    {
      name    = "PORTS_WEB"
      type    = "port"
      content = ["80", "443", "8080"]
    }
  ]
}
```

## Complete example

See the `examples/orange-box-dmz/` folder for a complete configuration:

- Orange Box configured in DMZ to OPNsense
- WAN interface in DHCP
- LAN interface in 192.168.10.0/24
- Base firewall rules
- Automatic outbound NAT
- DHCP server

## Security

### Mandatory rules

#### 1. Anti-lockout

**ALWAYS** include a rule allowing admin access:

```hcl
resource "opnsense_firewall_filter" "anti_lockout" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  protocol         = "tcp"
  source_net       = "lan"
  destination_net  = "(self)"
  destination_port = "443"
  description      = "ANTI-LOCKOUT: Admin access"
  sequence         = 1  # High priority
}
```

#### 2. Secure credentials

- **NEVER** commit API keys
- Use environment variables or vault
- Add `*.tfvars` to `.gitignore`

#### 3. HTTPS certificate

In production, use a valid certificate:

```hcl
provider "opnsense" {
  allow_insecure = false  # Require valid certificate
}
```

### Best practices

1. **Deny by default**: Block everything, allow explicitly
2. **Logging**: Enable logs on block rules
3. **Documentation**: Comment every rule
4. **Aliases**: Use aliases for readability
5. **Test**: Validate in lab before production

## Troubleshooting

### API connection error

```bash
# Test the connection
curl -k -u "api-key:api-secret" \
  "https://<opnsense-ip>/api/core/firmware/status"

# Check:
# - API enabled in OPNsense
# - Correct credentials
# - Firewall is not blocking
# - Certificate (if allow_insecure = false)
```

### Lockout (lost access)

1. Access via Proxmox console
2. Temporarily disable the firewall:
   ```bash
   pfctl -d
   ```
3. Fix via web interface
4. Re-enable:
   ```bash
   pfctl -e
   ```

### Corrupted Terraform state

```bash
# Import an existing resource
terraform import opnsense_firewall_filter.rule "uuid-of-the-rule"

# Refresh the state
terraform refresh
```

### Provider timeout

```hcl
provider "opnsense" {
  # Increase the timeout if needed
  request_timeout = 60
}
```

## Resources

- [OPNsense Documentation](https://docs.opnsense.org/)
- [Terraform Provider browningluke/opnsense](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs)
- [OPNsense API](https://docs.opnsense.org/development/api.html)
- [Terraform Best Practices](https://terraform-best-practices.com)
