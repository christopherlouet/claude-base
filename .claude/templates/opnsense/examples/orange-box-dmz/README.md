# Example: OPNsense behind Orange Box in DMZ

Complete Terraform configuration to deploy OPNsense behind an Orange box (Livebox) in DMZ mode.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Internet     │     │   Orange Box    │     │    OPNsense     │
│                 │────▶│  192.168.1.1    │────▶│   WAN: DHCP     │
│                 │     │   DMZ Mode      │     │   LAN: .10.1    │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                           ┌─────────────┴─────────────┐
                                           │       LAN 192.168.10.0/24 │
                                           │                           │
                                    ┌──────┴──────┐             ┌──────┴──────┐
                                    │   Servers   │             │   Clients   │
                                    │  .10.20+    │             │  DHCP       │
                                    └─────────────┘             └─────────────┘
```

## Prerequisites

### 1. OPNsense installed

- Proxmox VM or physical machine
- 2 network interfaces (WAN + LAN)
- API enabled (System > Settings > Administration)
- API user created with keys

### 2. Orange Box configured

1. Access the Livebox: `http://192.168.1.1`
2. Go to **Network > NAT/PAT > DMZ**
3. Enable DMZ to OPNsense's WAN IP
4. Optional: Disable the box's WiFi if OPNsense manages the network

### 3. Terraform installed

```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip
unzip terraform_1.9.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

## Usage

### 1. Configure credentials

```bash
# Environment variables (recommended)
export TF_VAR_opnsense_uri="https://192.168.10.1"
export TF_VAR_opnsense_api_key="your-api-key"
export TF_VAR_opnsense_api_secret="your-api-secret"
```

Or create a `terraform.tfvars` file (DO NOT COMMIT):

```hcl
opnsense_uri        = "https://192.168.10.1"
opnsense_api_key    = "your-api-key"
opnsense_api_secret = "your-api-secret"
```

### 2. Customize variables

Edit `variables.tf` or create `terraform.tfvars`:

```hcl
# Network
lan_ip           = "192.168.10.1"
lan_subnet       = 24
dhcp_range_start = "192.168.10.100"
dhcp_range_end   = "192.168.10.200"
local_domain     = "home.local"

# Interfaces (adapt to your hardware)
wan_device = "vtnet0"  # or em0, igb0...
lan_device = "vtnet1"  # or em1, igb1...
```

### 3. Deploy

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply the configuration
terraform apply

# View outputs
terraform output
terraform output summary
```

## What is configured

### Interfaces

| Interface | Configuration |
|-----------|---------------|
| WAN | DHCP (IP assigned by the box) |
| LAN | 192.168.10.1/24 (static) |

### Firewall

| Rule | Description |
|------|-------------|
| Anti-lockout | Admin access from LAN (seq: 1) |
| HTTP/HTTPS | Allow outbound web browsing |
| DNS | Allow DNS resolution |
| NTP | Allow time synchronization |
| ICMP | Allow outbound ping |
| Block all | Block and log everything else |

### Services

| Service | Configuration |
|---------|---------------|
| DHCP | Range 192.168.10.100-200 |
| DNS | Cloudflare forwarders (1.1.1.1) |

### Aliases

| Alias | Content |
|-------|---------|
| PORTS_WEB | 80, 443 |
| PORTS_ADMIN | 22, 443 |
| DNS_PUBLIC | 1.1.1.1, 1.0.0.1, 8.8.8.8, 8.8.4.4 |

## Customization

### Add a DHCP reservation

Uncomment in `main.tf`:

```hcl
resource "opnsense_dhcp_v4_static_map" "server_example" {
  interface   = "lan"
  mac         = "00:11:22:33:44:55"  # MAC of your server
  ipaddr      = "192.168.10.20"
  hostname    = "server"
  description = "Main server"
}
```

### Add a port forwarding

Uncomment in `main.tf`:

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
resource "opnsense_unbound_host_override" "server" {
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

### Lockout (lost access)

1. Access via Proxmox console
2. Disable the firewall: `pfctl -d`
3. Fix via web interface
4. Re-enable: `pfctl -e`

### Desynchronized state

```bash
# Refresh the state
terraform refresh

# Import an existing resource
terraform import opnsense_firewall_filter.rule "uuid-of-the-rule"
```

## Files

| File | Description |
|------|-------------|
| `main.tf` | Main configuration |
| `variables.tf` | Input variables |
| `outputs.tf` | Output values |
| `terraform.tfvars` | Custom values (DO NOT COMMIT) |

## Security

- **NEVER** commit API credentials
- Add `terraform.tfvars` and `*.tfstate*` to `.gitignore`
- Use environment variables in CI/CD
- Always keep the anti-lockout rule active
