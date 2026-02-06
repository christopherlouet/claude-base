---
sidebar_position: 10
title: "09 - Firewall OPNsense"
description: Configurez OPNsense comme firewall derrière une box opérateur avec Terraform
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Firewall OPNsense avec Terraform

<DifficultyBadge level="intermediate" /> **Durée estimée : 45 minutes**

Ce tutoriel vous montre comment configurer un firewall OPNsense en Infrastructure as Code avec Terraform, dans une architecture derrière une box opérateur (Orange, Free, SFR...) en mode DMZ.

## Objectifs

À la fin de ce tutoriel, vous saurez :
- Utiliser `/ops:ops-opnsense` pour gérer OPNsense via Terraform
- Configurer les interfaces WAN/LAN
- Créer des règles firewall sécurisées
- Configurer DHCP et DNS
- Gérer les aliases et le NAT

## Prérequis

- OPNsense installé (VM Proxmox ou machine physique)
- 2 interfaces réseau (WAN + LAN)
- API OPNsense activée avec clés API
- Terraform installé localement
- Box opérateur configurée en mode DMZ

## Architecture cible

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Internet     │     │  Box Opérateur  │     │    OPNsense     │
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

## Étape 1 : Préparer OPNsense

### Activer l'API

1. Se connecter à OPNsense : `https://192.168.10.1`
2. **System > Settings > Administration**
3. Activer **Enable API**
4. Sauvegarder

### Créer un utilisateur API

1. **System > Access > Users**
2. Créer un nouvel utilisateur (ex: `terraform-api`)
3. Dans l'onglet **API Keys**, générer une clé
4. **NOTER** la clé et le secret (affichés une seule fois)

### Configurer la box en DMZ

1. Accéder à la box : `http://192.168.1.1`
2. **Réseau > NAT/PAT > DMZ** (ou équivalent selon opérateur)
3. Activer la DMZ vers l'IP WAN d'OPNsense (ex: 192.168.1.50)
4. Tous les ports seront redirigés vers OPNsense

## Étape 2 : Initialiser le projet Terraform

```bash
/ops:ops-opnsense "Créer la structure de projet pour configurer OPNsense"
```

### Structure de fichiers

```
opnsense-infra/
├── main.tf              # Configuration principale
├── variables.tf         # Variables d'entrée
├── outputs.tf           # Outputs
├── terraform.tfvars     # Valeurs (NE PAS COMMITER)
└── .gitignore
```

### Configuration du provider

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
  allow_insecure = true  # false en production avec certificat valide
}
```

### Variables

**`variables.tf`**
```hcl
# Provider
variable "opnsense_uri" {
  description = "URL de l'interface OPNsense"
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

# Réseau
variable "lan_ip" {
  description = "Adresse IP du LAN OPNsense"
  type        = string
  default     = "192.168.10.1"
}

variable "lan_subnet" {
  description = "Masque de sous-réseau LAN"
  type        = number
  default     = 24
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

variable "local_domain" {
  description = "Domaine local"
  type        = string
  default     = "home.local"
}
```

### Credentials

```bash
# Option 1 : Variables d'environnement (recommandé)
export TF_VAR_opnsense_uri="https://192.168.10.1"
export TF_VAR_opnsense_api_key="votre-api-key"
export TF_VAR_opnsense_api_secret="votre-api-secret"

# Option 2 : Fichier terraform.tfvars (NE PAS COMMITER)
cat > terraform.tfvars << 'EOF'
opnsense_uri        = "https://192.168.10.1"
opnsense_api_key    = "votre-api-key"
opnsense_api_secret = "votre-api-secret"
EOF
```

## Étape 3 : Configurer les interfaces

```bash
/ops:ops-opnsense "Configurer les interfaces WAN (DHCP) et LAN (statique)"
```

**`main.tf`** - Section Interfaces
```hcl
# =============================================================================
# Interfaces
# =============================================================================

# Interface WAN - Connectée à la Box (reçoit IP via DMZ)
resource "opnsense_interface" "wan" {
  device        = "vtnet0"    # Adapter selon votre matériel
  description   = "WAN - Box Opérateur"
  ipv4_type     = "dhcp"
  enabled       = true
  block_private = true        # Bloquer RFC1918 sur WAN
  block_bogons  = true        # Bloquer adresses invalides
}

# Interface LAN - Réseau local
resource "opnsense_interface" "lan" {
  device      = "vtnet1"      # Adapter selon votre matériel
  description = "LAN - Réseau local"
  ipv4_type   = "static"
  ipv4_addr   = var.lan_ip
  ipv4_mask   = var.lan_subnet
  enabled     = true
}
```

:::tip Identifier les interfaces
Pour connaître les noms de vos interfaces :
- Via OPNsense : **Interfaces > Assignments**
- Via console : `ifconfig -a`
- Noms courants : `vtnet0/vtnet1` (virtIO), `em0/em1` (Intel), `igb0/igb1` (Intel Gigabit)
:::

## Étape 4 : Créer les aliases

Les aliases permettent de grouper des adresses IP ou des ports pour simplifier les règles.

```bash
/ops:ops-opnsense "Créer des aliases pour les ports web et DNS publics"
```

**`main.tf`** - Section Aliases
```hcl
# =============================================================================
# Aliases
# =============================================================================

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
  description = "Serveurs DNS publics (Cloudflare + Google)"
}
```

## Étape 5 : Configurer le firewall

:::danger Règle Anti-lockout OBLIGATOIRE
La règle anti-lockout doit **TOUJOURS** être en sequence 1. Sans elle, vous perdrez l'accès à OPNsense après application des règles.
:::

```bash
/ops:ops-opnsense "Créer les règles firewall avec anti-lockout"
```

**`main.tf`** - Section Firewall
```hcl
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
  sequence         = 1           # TOUJOURS en premier
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

# Autoriser DNS sortant (TCP - pour DNSSEC)
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
  interface       = "lan"
  direction       = "in"
  action          = "pass"
  ip_protocol     = "inet"
  protocol        = "icmp"
  source_net      = "lannet"
  destination_net = "any"
  description     = "Autoriser ICMP (ping) sortant"
  sequence        = 14
  enabled         = true
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
  sequence        = 65535        # Toujours en dernier
  enabled         = true
}
```

## Étape 6 : Configurer DHCP et DNS

```bash
/ops:ops-opnsense "Configurer le serveur DHCP et les forwarders DNS"
```

**`main.tf`** - Section Services
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
  dns_servers = [var.lan_ip]          # OPNsense comme DNS
  domain      = var.local_domain
  lease_time  = 86400                  # 24 heures
}

# =============================================================================
# DNS (Unbound Forwarders)
# =============================================================================

# Forwarder vers Cloudflare (primaire)
resource "opnsense_unbound_forward" "cloudflare_1" {
  enabled  = true
  host     = "1.1.1.1"
  port     = 53
  priority = 10
}

# Forwarder vers Cloudflare (secondaire)
resource "opnsense_unbound_forward" "cloudflare_2" {
  enabled  = true
  host     = "1.0.0.1"
  port     = 53
  priority = 20
}
```

## Étape 7 : Déployer

### Initialiser Terraform

```bash
terraform init
```

### Prévisualiser les changements

```bash
terraform plan
```

### Appliquer la configuration

```bash
terraform apply
```

### Vérifier

```bash
terraform output summary
```

## Étape 8 : Personnalisation (optionnel)

### Ajouter une réservation DHCP

```hcl
resource "opnsense_dhcp_v4_static_map" "server_web" {
  interface   = "lan"
  mac         = "00:11:22:33:44:55"
  ipaddr      = "192.168.10.20"
  hostname    = "server-web"
  description = "Serveur web principal"
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

### Ajouter une entrée DNS locale

```hcl
resource "opnsense_unbound_host_override" "server_web" {
  enabled  = true
  hostname = "server"
  domain   = "home.local"
  server   = "192.168.10.20"
}
```

## Troubleshooting

### Erreur de connexion API

```bash
# Tester la connexion
curl -k -u "$TF_VAR_opnsense_api_key:$TF_VAR_opnsense_api_secret" \
  "$TF_VAR_opnsense_uri/api/core/firmware/status"
```

**Vérifier** :
1. API activée dans OPNsense
2. Utilisateur API avec permissions
3. Firewall n'est pas bloquant
4. Certificat HTTPS valide ou `allow_insecure = true`

### Lockout (accès perdu)

Via console Proxmox ou accès physique :
```bash
# Désactiver le firewall temporairement
pfctl -d

# Corriger via interface web
# ...

# Réactiver le firewall
pfctl -e
```

### State désynchronisé

```bash
# Rafraîchir le state
terraform refresh

# Importer une ressource existante
terraform import opnsense_firewall_filter.rule "uuid-de-la-regle"

# Forcer recréation
terraform taint opnsense_firewall_filter.rule
terraform apply
```

## Bonnes pratiques

| Pratique | Pourquoi |
|----------|----------|
| **Anti-lockout en sequence 1** | Éviter de perdre l'accès |
| **Utiliser des aliases** | Lisibilité et maintenabilité |
| **Documenter chaque règle** | Audit facilité |
| **Logger les règles block** | Détection d'intrusion |
| **Tester en lab** | Éviter les lockouts |
| **Backup avant apply** | Rollback possible |
| **Ne jamais commiter les credentials** | Sécurité |

## Résumé

Vous avez appris à :
- ✅ Configurer OPNsense avec Terraform
- ✅ Créer des interfaces WAN/LAN
- ✅ Gérer les aliases
- ✅ Créer des règles firewall sécurisées
- ✅ Configurer DHCP et DNS
- ✅ Personnaliser avec réservations et port forwarding

## Commandes utilisées

| Commande | Usage |
|----------|-------|
| `/ops:ops-opnsense` | Configuration OPNsense complète |
| `/ops:ops-infra-code` | Infrastructure as Code générique |

## Voir aussi

- [Commande `/ops:ops-opnsense`](/docs/commands/ops/ops-opnsense)
- [Skill `ops-opnsense`](/docs/skills/ops-opnsense)
- [Exemple OPNsense](/docs/examples/ops/opnsense-config)
- [Tutorial Proxmox](/docs/tutorials/proxmox-infra)
