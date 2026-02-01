---
sidebar_position: 5
title: OPNsense Firewall
description: Exemple de configuration OPNsense avec Terraform derrière une box Orange
---

# OPNsense Firewall avec Terraform

Cet exemple montre comment configurer un firewall OPNsense en Infrastructure as Code avec Terraform, dans une architecture derrière une box Orange en mode DMZ.

## Commande utilisée

```bash
/ops:ops-opnsense "Configurer OPNsense derrière box Orange avec firewall, DHCP et DNS"
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

## Structure générée

```
opnsense-config/
├── main.tf              # Configuration principale
├── variables.tf         # Variables d'entrée
├── outputs.tf           # Outputs
└── terraform.tfvars     # Valeurs (NE PAS COMMITER)
```

## Code Terraform

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
  description = "URL de l'interface OPNsense (ex: https://192.168.10.1)"
  type        = string
}

variable "opnsense_api_key" {
  description = "Clé API OPNsense"
  type        = string
  sensitive   = true
}

variable "opnsense_api_secret" {
  description = "Secret API OPNsense"
  type        = string
  sensitive   = true
}

variable "allow_insecure" {
  description = "Autoriser les certificats auto-signés"
  type        = bool
  default     = true
}

variable "lan_ip" {
  description = "Adresse IP du LAN OPNsense"
  type        = string
  default     = "192.168.10.1"
}

variable "dhcp_range_start" {
  description = "Première IP de la plage DHCP"
  type        = string
  default     = "192.168.10.100"
}

variable "dhcp_range_end" {
  description = "Dernière IP de la plage DHCP"
  type        = string
  default     = "192.168.10.200"
}
```

### `main.tf`

```hcl
# =============================================================================
# Interfaces
# =============================================================================

# Interface WAN - Connectée à la Box Orange (reçoit IP via DMZ)
resource "opnsense_interface" "wan" {
  device        = "vtnet0"
  description   = "WAN - Box Orange"
  ipv4_type     = "dhcp"
  enabled       = true
  block_private = true
  block_bogons  = true
}

# Interface LAN - Réseau local
resource "opnsense_interface" "lan" {
  device      = "vtnet1"
  description = "LAN - Réseau local"
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
  description = "Ports HTTP/HTTPS"
}

resource "opnsense_firewall_alias" "dns_public" {
  name        = "DNS_PUBLIC"
  type        = "host"
  content     = ["1.1.1.1", "1.0.0.1", "8.8.8.8", "8.8.4.4"]
  description = "Serveurs DNS publics"
}

# =============================================================================
# Règles Firewall
# =============================================================================

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
  description = "Réseau LAN configuré"
  value       = "${opnsense_interface.lan.ipv4_addr}/${opnsense_interface.lan.ipv4_mask}"
}

output "dhcp_range" {
  description = "Plage DHCP"
  value       = "${opnsense_dhcp_v4_server.lan.range_from} - ${opnsense_dhcp_v4_server.lan.range_to}"
}

output "admin_url" {
  description = "URL d'administration OPNsense"
  value       = "https://${opnsense_interface.lan.ipv4_addr}"
}

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
    ║
    ║  Firewall: 4 règles (anti-lockout + web + dns + block)
    ╚═══════════════════════════════════════════════════════════════╝

    Accès admin: https://${opnsense_interface.lan.ipv4_addr}
  EOT
}
```

## Déploiement

### 1. Configurer les credentials

```bash
# Variables d'environnement (recommandé)
export TF_VAR_opnsense_uri="https://192.168.10.1"
export TF_VAR_opnsense_api_key="votre-api-key"
export TF_VAR_opnsense_api_secret="votre-api-secret"
```

### 2. Initialiser et appliquer

```bash
terraform init
terraform plan
terraform apply
```

### 3. Vérifier

```bash
terraform output summary
```

## Personnalisation

### Ajouter une réservation DHCP

```hcl
resource "opnsense_dhcp_v4_static_map" "server" {
  interface   = "lan"
  mac         = "00:11:22:33:44:55"
  ipaddr      = "192.168.10.20"
  hostname    = "server"
  description = "Serveur principal"
}
```

### Ajouter un port forwarding

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
  description      = "HTTPS vers serveur web"
  nat_reflection   = "enable"
  filter_rule_association = "add-associated"
}
```

## Points de sécurité

:::danger Règle Anti-lockout
La règle anti-lockout (sequence 1) est **CRITIQUE**. Ne jamais la supprimer ou vous perdrez l'accès admin.
:::

:::warning Credentials
- Ne jamais commiter `terraform.tfvars` avec les credentials
- Utiliser des variables d'environnement en CI/CD
- Ajouter `*.tfstate*` et `terraform.tfvars` au `.gitignore`
:::

## Troubleshooting

### Erreur connexion API

```bash
curl -k -u "$TF_VAR_opnsense_api_key:$TF_VAR_opnsense_api_secret" \
  "$TF_VAR_opnsense_uri/api/core/firmware/status"
```

### Lockout (accès perdu)

Via console Proxmox/local :
```bash
pfctl -d          # Désactiver le firewall
# Corriger via interface web
pfctl -e          # Réactiver le firewall
```

## Voir aussi

- [Commande `/ops:ops-opnsense`](/docs/commands/ops/ops-opnsense)
- [Skill `opnsense-configuration`](/docs/skills/opnsense-configuration)
- [Agent `ops-opnsense`](/docs/agents/ops-opnsense)
- [Exemple VM Proxmox](/docs/examples/ops/proxmox-vm)
