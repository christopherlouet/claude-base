# Exemple: OPNsense derrière Box Orange en DMZ

Configuration Terraform complète pour déployer OPNsense derrière une box Orange (Livebox) en mode DMZ.

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

## Prérequis

### 1. OPNsense installé

- VM Proxmox ou machine physique
- 2 interfaces réseau (WAN + LAN)
- API activée (System > Settings > Administration)
- Utilisateur API créé avec clés

### 2. Box Orange configurée

1. Accéder à la Livebox: `http://192.168.1.1`
2. Aller dans **Réseau > NAT/PAT > DMZ**
3. Activer la DMZ vers l'IP WAN d'OPNsense
4. Optionnel: Désactiver le WiFi de la box si OPNsense gère le réseau

### 3. Terraform installé

```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip
unzip terraform_1.9.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

## Utilisation

### 1. Configurer les credentials

```bash
# Variables d'environnement (recommandé)
export TF_VAR_opnsense_uri="https://192.168.10.1"
export TF_VAR_opnsense_api_key="votre-api-key"
export TF_VAR_opnsense_api_secret="votre-api-secret"
```

Ou créer un fichier `terraform.tfvars` (NE PAS COMMITER):

```hcl
opnsense_uri        = "https://192.168.10.1"
opnsense_api_key    = "votre-api-key"
opnsense_api_secret = "votre-api-secret"
```

### 2. Personnaliser les variables

Éditer `variables.tf` ou créer `terraform.tfvars`:

```hcl
# Réseau
lan_ip           = "192.168.10.1"
lan_subnet       = 24
dhcp_range_start = "192.168.10.100"
dhcp_range_end   = "192.168.10.200"
local_domain     = "home.local"

# Interfaces (adapter selon votre matériel)
wan_device = "vtnet0"  # ou em0, igb0...
lan_device = "vtnet1"  # ou em1, igb1...
```

### 3. Déployer

```bash
# Initialiser Terraform
terraform init

# Prévisualiser les changements
terraform plan

# Appliquer la configuration
terraform apply

# Voir les outputs
terraform output
terraform output summary
```

## Ce qui est configuré

### Interfaces

| Interface | Configuration |
|-----------|---------------|
| WAN | DHCP (IP assignée par la box) |
| LAN | 192.168.10.1/24 (statique) |

### Firewall

| Règle | Description |
|-------|-------------|
| Anti-lockout | Accès admin depuis LAN (seq: 1) |
| HTTP/HTTPS | Autoriser navigation web sortante |
| DNS | Autoriser résolution DNS |
| NTP | Autoriser synchronisation horaire |
| ICMP | Autoriser ping sortant |
| Block all | Bloquer et logger tout le reste |

### Services

| Service | Configuration |
|---------|---------------|
| DHCP | Plage 192.168.10.100-200 |
| DNS | Forwarders Cloudflare (1.1.1.1) |

### Aliases

| Alias | Contenu |
|-------|---------|
| PORTS_WEB | 80, 443 |
| PORTS_ADMIN | 22, 443 |
| DNS_PUBLIC | 1.1.1.1, 1.0.0.1, 8.8.8.8, 8.8.4.4 |

## Personnalisation

### Ajouter une réservation DHCP

Décommenter dans `main.tf`:

```hcl
resource "opnsense_dhcp_v4_static_map" "server_example" {
  interface   = "lan"
  mac         = "00:11:22:33:44:55"  # MAC de votre serveur
  ipaddr      = "192.168.10.20"
  hostname    = "server"
  description = "Serveur principal"
}
```

### Ajouter un port forwarding

Décommenter dans `main.tf`:

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
resource "opnsense_unbound_host_override" "server" {
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

### Lockout (accès perdu)

1. Accéder via console Proxmox
2. Désactiver le firewall: `pfctl -d`
3. Corriger via interface web
4. Réactiver: `pfctl -e`

### State désynchronisé

```bash
# Rafraîchir le state
terraform refresh

# Importer une ressource existante
terraform import opnsense_firewall_filter.rule "uuid-de-la-regle"
```

## Fichiers

| Fichier | Description |
|---------|-------------|
| `main.tf` | Configuration principale |
| `variables.tf` | Variables d'entrée |
| `outputs.tf` | Valeurs de sortie |
| `terraform.tfvars` | Valeurs personnalisées (NE PAS COMMITER) |

## Sécurité

- **NE JAMAIS** commiter les credentials API
- Ajouter `terraform.tfvars` et `*.tfstate*` à `.gitignore`
- Utiliser des variables d'environnement en CI/CD
- Toujours garder la règle anti-lockout active
