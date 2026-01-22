# Templates OPNsense - Infrastructure as Code

Templates Terraform pour gérer OPNsense de manière déclarative.

## Table des matières

- [Prérequis](#prérequis)
- [Structure](#structure)
- [Configuration initiale](#configuration-initiale)
- [Modules disponibles](#modules-disponibles)
- [Exemple complet](#exemple-complet)
- [Sécurité](#sécurité)
- [Troubleshooting](#troubleshooting)

## Prérequis

### OPNsense

- **Version**: 24.1 ou supérieure
- **API activée**: System > Settings > Administration > Enable API
- **Utilisateur API**: System > Access > Users > Créer user avec clés API

### Terraform

- **Version**: 1.9+
- **Provider**: `browningluke/opnsense` >= 0.11

### Réseau

- OPNsense accessible depuis la machine Terraform
- Ports 443 (HTTPS) et 80 (HTTP si non-SSL)

## Structure

```
.claude/templates/opnsense/
├── README.md                 # Ce fichier
├── provider-template.tf      # Configuration provider
├── interfaces-module.tf      # Module interfaces WAN/LAN
├── firewall-module.tf        # Module règles firewall
├── nat-module.tf             # Module NAT/port forward
├── services-module.tf        # Module DHCP/DNS
├── aliases-module.tf         # Module groupes d'adresses
└── examples/
    └── orange-box-dmz/       # Exemple complet Box Orange
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## Configuration initiale

### 1. Créer un template VM OPNsense (Proxmox)

```bash
# Télécharger l'ISO OPNsense
wget https://mirror.ams1.nl.leaseweb.net/opnsense/releases/24.1/OPNsense-24.1-dvd-amd64.iso

# Créer VM dans Proxmox
# - CPU: 2 cores
# - RAM: 4 GB
# - Disk: 32 GB
# - Network: 2 interfaces (WAN + LAN)

# Installer OPNsense manuellement
# Convertir en template après configuration de base
```

### 2. Activer l'API OPNsense

1. Connectez-vous à l'interface web: `https://<IP-OPNsense>`
2. Allez dans **System > Settings > Administration**
3. Cochez **Enable API**
4. Sauvegardez

### 3. Créer un utilisateur API

1. **System > Access > Users**
2. Cliquez **+** pour ajouter un utilisateur
3. Nom: `terraform`
4. Cochez **Generate scrambled password**
5. Dans la section **API keys**, cliquez **+**
6. Téléchargez les clés (fichier `.txt`)
7. Assignez les permissions:
   - `GUI All pages` (pour accès complet)
   - Ou permissions granulaires selon besoins

### 4. Configurer les credentials

```bash
# Méthode recommandée: variables d'environnement
export TF_VAR_opnsense_uri="https://192.168.10.1"
export TF_VAR_opnsense_api_key="votre-api-key"
export TF_VAR_opnsense_api_secret="votre-api-secret"

# Alternative: terraform.tfvars (NE PAS COMMITER)
# Ajouter terraform.tfvars à .gitignore
```

## Modules disponibles

### interfaces-module.tf

Configure les interfaces réseau (WAN, LAN, VLANs).

```hcl
module "interfaces" {
  source = "./.claude/templates/opnsense"

  wan_interface = "vtnet0"
  wan_type      = "dhcp"  # ou "static"

  lan_interface = "vtnet1"
  lan_ip        = "192.168.10.1"
  lan_subnet    = 24
}
```

### firewall-module.tf

Gère les règles de pare-feu.

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
      description = "Autoriser HTTP/HTTPS sortant"
    }
  ]
}
```

### nat-module.tf

Configure NAT outbound et port forwarding.

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
      description   = "HTTPS vers serveur web"
    }
  ]
}
```

### services-module.tf

Configure DHCP et DNS.

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

Crée des groupes d'adresses pour simplifier les règles.

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

## Exemple complet

Voir le dossier `examples/orange-box-dmz/` pour une configuration complète:

- Box Orange configurée en DMZ vers OPNsense
- Interface WAN en DHCP
- Interface LAN en 192.168.10.0/24
- Règles firewall de base
- NAT outbound automatique
- Serveur DHCP

## Sécurité

### Règles obligatoires

#### 1. Anti-lockout

**TOUJOURS** inclure une règle permettant l'accès admin:

```hcl
resource "opnsense_firewall_filter" "anti_lockout" {
  interface        = "lan"
  direction        = "in"
  action           = "pass"
  protocol         = "tcp"
  source_net       = "lan"
  destination_net  = "(self)"
  destination_port = "443"
  description      = "ANTI-LOCKOUT: Accès admin"
  sequence         = 1  # Priorité haute
}
```

#### 2. Credentials sécurisés

- **NE JAMAIS** commiter les clés API
- Utiliser variables d'environnement ou vault
- Ajouter `*.tfvars` à `.gitignore`

#### 3. Certificat HTTPS

En production, utiliser un certificat valide:

```hcl
provider "opnsense" {
  allow_insecure = false  # Exiger certificat valide
}
```

### Bonnes pratiques

1. **Deny by default**: Bloquer tout, autoriser explicitement
2. **Logging**: Activer les logs sur les règles block
3. **Documentation**: Commenter chaque règle
4. **Aliases**: Utiliser des aliases pour la lisibilité
5. **Test**: Valider en lab avant production

## Troubleshooting

### Erreur de connexion API

```bash
# Tester la connexion
curl -k -u "api-key:api-secret" \
  "https://<opnsense-ip>/api/core/firmware/status"

# Vérifier:
# - API activée dans OPNsense
# - Credentials corrects
# - Pare-feu n'est pas bloquant
# - Certificat (si allow_insecure = false)
```

### Lockout (accès perdu)

1. Accéder via console Proxmox
2. Désactiver temporairement le firewall:
   ```bash
   pfctl -d
   ```
3. Corriger via interface web
4. Réactiver:
   ```bash
   pfctl -e
   ```

### Terraform state corrompu

```bash
# Importer une ressource existante
terraform import opnsense_firewall_filter.rule "uuid-de-la-regle"

# Rafraîchir le state
terraform refresh
```

### Provider timeout

```hcl
provider "opnsense" {
  # Augmenter le timeout si nécessaire
  request_timeout = 60
}
```

## Ressources

- [Documentation OPNsense](https://docs.opnsense.org/)
- [Provider Terraform browningluke/opnsense](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs)
- [API OPNsense](https://docs.opnsense.org/development/api.html)
- [Best Practices Terraform](https://terraform-best-practices.com)
