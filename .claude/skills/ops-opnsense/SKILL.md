---
name: ops-opnsense
description: Configuration OPNsense via Terraform. Declencher pour interfaces, firewall, NAT, DHCP/DNS, aliases.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Configuration OPNsense (Terraform)

Guide complet pour configurer OPNsense de manière déclarative avec Terraform et le provider `browningluke/opnsense`.

## Quand utiliser ce Skill

**Activer ce skill pour :**
- Configurer les interfaces réseau OPNsense (WAN, LAN, VLANs)
- Gérer les règles de pare-feu
- Configurer NAT et port forwarding
- Gérer les services DHCP et DNS
- Créer des aliases pour simplifier les règles

**Ne pas utiliser pour :**
- Installation initiale OPNsense (voir documentation manuelle)
- Provisioning VM (utiliser `/ops-proxmox`)
- Plugins OPNsense avancés (HAProxy, Suricata)

## Provider Terraform

| Attribut | Valeur |
|----------|--------|
| **Provider** | `browningluke/opnsense` |
| **Version** | >= 0.11 |
| **Documentation** | https://registry.terraform.io/providers/browningluke/opnsense/latest/docs |
| **GitHub** | https://github.com/browningluke/terraform-provider-opnsense |

### Configuration du Provider

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
  api_key             = var.opnsense_api_key    # Sensible
  api_secret          = var.opnsense_api_secret # Sensible
  allow_insecure = true                    # false en production
}
```

## Patterns de Configuration

### 1. Interfaces Réseau

```hcl
# Interface WAN (DHCP depuis box opérateur)
resource "opnsense_interface" "wan" {
  device        = "vtnet0"
  description   = "WAN - Box Orange"
  ipv4_type     = "dhcp"
  block_private = true
  block_bogons  = true
}

# Interface LAN (IP statique)
resource "opnsense_interface" "lan" {
  device      = "vtnet1"
  description = "LAN - Réseau local"
  ipv4_type   = "static"
  ipv4_addr   = "192.168.10.1"
  ipv4_mask   = 24
}
```

### 2. Règles Firewall (CRITIQUE: Anti-lockout)

```hcl
# OBLIGATOIRE: Règle anti-lockout (TOUJOURS en premier)
resource "opnsense_firewall_filter" "anti_lockout" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "(self)"
  destination_port = "443"
  description      = "ANTI-LOCKOUT: Accès admin"
  sequence         = 1
}

# Autoriser HTTP/HTTPS sortant
resource "opnsense_firewall_filter" "lan_to_web" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = "any"
  destination_port = "80,443"
  description      = "Autoriser HTTP/HTTPS sortant"
  sequence         = 10
}

# Bloquer tout le reste (deny by default)
resource "opnsense_firewall_filter" "lan_block_all" {
  interface   = "lan"
  direction   = "in"
  action      = "block"
  protocol    = "any"
  source_net  = "any"
  destination_net = "any"
  log         = true
  description = "Bloquer et logger tout le reste"
  sequence    = 65535
}
```

### 3. NAT / Port Forwarding

```hcl
# Port forward HTTPS vers serveur web interne
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

# SSH sur port non-standard
resource "opnsense_nat_port_forward" "ssh_to_server" {
  interface        = "wan"
  protocol         = "tcp"
  source_net       = "any"
  source_port      = "2222"
  destination_net  = "wanip"
  destination_port = "2222"
  target           = "192.168.10.10"
  local_port       = "22"
  description      = "SSH vers serveur (port 2222)"
}
```

### 4. Services DHCP/DNS

```hcl
# Serveur DHCP sur LAN
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

# Réservation DHCP
resource "opnsense_dhcp_v4_static_map" "server_web" {
  interface   = "lan"
  mac         = "00:11:22:33:44:55"
  ipaddr      = "192.168.10.20"
  hostname    = "server-web"
  description = "Serveur web principal"
}

# DNS forwarder
resource "opnsense_unbound_forward" "cloudflare" {
  enabled  = true
  host     = "1.1.1.1"
  port     = 53
  priority = 10
}

# Entrée DNS locale
resource "opnsense_unbound_host_override" "server_web" {
  enabled  = true
  hostname = "server"
  domain   = "home.local"
  server   = "192.168.10.20"
}
```

### 5. Aliases

```hcl
# Alias de serveurs
resource "opnsense_firewall_alias" "servers_web" {
  name        = "SERVERS_WEB"
  type        = "host"
  content     = ["192.168.10.20", "192.168.10.21"]
  description = "Serveurs web internes"
}

# Alias de ports
resource "opnsense_firewall_alias" "ports_web" {
  name        = "PORTS_WEB"
  type        = "port"
  content     = ["80", "443", "8080"]
  description = "Ports services web"
}

# Utilisation dans une règle
resource "opnsense_firewall_filter" "to_web_servers" {
  interface        = "lan"
  action           = "pass"
  protocol         = "tcp"
  source_net       = "lannet"
  destination_net  = opnsense_firewall_alias.servers_web.name
  destination_port = opnsense_firewall_alias.ports_web.name
  description      = "Accès aux serveurs web"
}
```

## Sécurité

### Règles Obligatoires

1. **Anti-lockout** (sequence = 1)
   - TOUJOURS présente
   - Permet accès admin depuis LAN
   - Ne jamais supprimer

2. **Deny by default** (sequence = 65535)
   - Bloquer tout ce qui n'est pas explicitement autorisé
   - Logger pour détecter les tentatives

3. **Credentials sécurisés**
   - Variables d'environnement ou terraform.tfvars
   - JAMAIS dans le code
   - JAMAIS commité

### Bonnes Pratiques

| Pratique | Pourquoi |
|----------|----------|
| Utiliser des aliases | Lisibilité et maintenabilité |
| Documenter chaque règle | Audit facilité |
| Logger les règles block | Détection d'intrusion |
| Tester en lab | Éviter les lockouts |
| Backup avant apply | Rollback possible |

## Architecture Box Opérateur + OPNsense

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Internet      │     │   Box Orange    │     │    OPNsense     │
│                 │────▶│   (192.168.1.1) │────▶│   WAN: DHCP     │
│                 │     │   Mode DMZ      │     │   LAN: .10.1    │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                           ┌─────────────┴─────────────┐
                                           │                           │
                                    ┌──────┴──────┐             ┌──────┴──────┐
                                    │  Serveur    │             │   Client    │
                                    │  .10.20     │             │   DHCP      │
                                    └─────────────┘             └─────────────┘
```

### Configuration Box Orange en DMZ

1. Accéder à la Livebox: `http://192.168.1.1`
2. Réseau > NAT/PAT > DMZ
3. Activer DMZ vers l'IP WAN d'OPNsense
4. Tous les ports sont redirigés vers OPNsense

## WireGuard VPN (P3)

Configuration d'un serveur VPN WireGuard:

```hcl
# Interface WireGuard
resource "opnsense_wireguard_server" "vpn" {
  name         = "wg0"
  enabled      = true
  listen_port  = 51820
  tunnel_addr  = "10.10.10.1/24"
  dns          = "192.168.10.1"
  private_key  = var.wireguard_private_key  # Sensible
}

# Peer (client VPN)
resource "opnsense_wireguard_peer" "laptop" {
  server_id   = opnsense_wireguard_server.vpn.id
  name        = "laptop-chris"
  public_key  = "PUBLIC_KEY_DU_CLIENT"
  allowed_ips = "10.10.10.2/32"
}

# Règle firewall pour WireGuard
resource "opnsense_firewall_filter" "wireguard_in" {
  interface        = "wan"
  direction        = "in"
  action           = "pass"
  protocol         = "udp"
  destination_port = "51820"
  description      = "WireGuard VPN"
}
```

## Monitoring Prometheus (P3)

### Installation node_exporter

1. Installer le package `node_exporter` via OPNsense
2. System > Services > node_exporter
3. Activer et configurer le port (9100)

### Configuration Prometheus

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'opnsense'
    static_configs:
      - targets: ['192.168.10.1:9100']
    metrics_path: /metrics
```

### Métriques utiles

| Métrique | Description |
|----------|-------------|
| `node_network_receive_bytes_total` | Trafic entrant |
| `node_network_transmit_bytes_total` | Trafic sortant |
| `node_cpu_seconds_total` | Utilisation CPU |
| `node_memory_MemAvailable_bytes` | Mémoire disponible |
| `node_filesystem_avail_bytes` | Espace disque |

## Troubleshooting

### Erreur connexion API

```bash
# Tester la connexion
curl -k -u "api-key:api-secret" \
  "https://192.168.10.1/api/core/firmware/status"

# Vérifier:
# 1. API activée (System > Settings > Administration)
# 2. User API avec permissions
# 3. Firewall n'est pas bloquant
# 4. Certificat HTTPS
```

### Lockout (accès perdu)

```bash
# Via console Proxmox/local
pfctl -d                    # Désactiver firewall
# Corriger via interface web
pfctl -e                    # Réactiver firewall
```

### State Terraform désynchronisé

```bash
# Importer ressource existante
terraform import opnsense_firewall_filter.rule "uuid"

# Rafraîchir
terraform refresh

# Forcer recréation
terraform taint opnsense_firewall_filter.rule
terraform apply
```

## Templates disponibles

Les templates sont dans `.claude/templates/opnsense/`:

| Template | Description |
|----------|-------------|
| `provider-template.tf` | Configuration provider |
| `interfaces-module.tf` | Interfaces WAN/LAN |
| `firewall-module.tf` | Règles firewall |
| `nat-module.tf` | NAT/port forward |
| `services-module.tf` | DHCP/DNS |
| `aliases-module.tf` | Groupes d'adresses |
| `examples/orange-box-dmz/` | Exemple complet |

## Ressources

- [Documentation OPNsense](https://docs.opnsense.org/)
- [Provider Terraform](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs)
- [API OPNsense](https://docs.opnsense.org/development/api.html)
- [WireGuard OPNsense](https://docs.opnsense.org/manual/how-tos/wireguard-client.html)
