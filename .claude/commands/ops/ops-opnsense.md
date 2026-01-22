# Agent OPS-OPNSENSE

Infrastructure as Code pour OPNsense. Configurer et gérer un pare-feu OPNsense via Terraform.

## Contexte
$ARGUMENTS

## Objectif

Aider l'utilisateur à configurer et gérer OPNsense de manière déclarative avec Terraform.

## Capacités

### Configuration supportée

| Composant | Description |
|-----------|-------------|
| **Interfaces** | WAN, LAN, VLANs |
| **Firewall** | Règles allow/deny, anti-lockout |
| **NAT** | Outbound NAT, port forwarding |
| **Services** | DHCP, DNS (Unbound) |
| **Aliases** | Groupes d'IPs, réseaux, ports |

### Provider Terraform

- **Provider**: `browningluke/opnsense`
- **Version**: >= 0.11
- **Documentation**: https://registry.terraform.io/providers/browningluke/opnsense/latest/docs

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   1. PRÉREQUIS                                                  │
│      │                                                          │
│      ├── OPNsense installé et accessible                        │
│      ├── API OPNsense activée                                   │
│      └── Clés API générées                                      │
│                                                                 │
│   2. CONFIGURATION                                              │
│      │                                                          │
│      ├── Interfaces (WAN/LAN)                                   │
│      ├── Firewall rules                                         │
│      ├── NAT/Port forwarding                                    │
│      └── Services (DHCP/DNS)                                    │
│                                                                 │
│   3. DÉPLOIEMENT                                                │
│      │                                                          │
│      ├── terraform init                                         │
│      ├── terraform plan                                         │
│      └── terraform apply                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Templates disponibles

Les templates sont dans `.claude/templates/opnsense/`:

| Template | Description |
|----------|-------------|
| `provider-template.tf` | Configuration du provider OPNsense |
| `interfaces-module.tf` | Module interfaces WAN/LAN |
| `firewall-module.tf` | Module règles firewall |
| `nat-module.tf` | Module NAT et port forwarding |
| `services-module.tf` | Module DHCP/DNS |
| `aliases-module.tf` | Module groupes d'adresses |

### Exemple complet

Voir `examples/orange-box-dmz/` pour une configuration complète OPNsense derrière une box Orange.

## Commandes Terraform

```bash
# Initialiser le projet
terraform init

# Prévisualiser les changements
terraform plan

# Appliquer la configuration
terraform apply

# Détruire l'infrastructure (ATTENTION)
terraform destroy
```

## Prérequis OPNsense

### 1. Activer l'API

1. Connectez-vous à OPNsense: `https://<IP>`
2. System > Settings > Administration
3. Cochez "Enable API"
4. Sauvegardez

### 2. Créer un utilisateur API

1. System > Access > Users
2. Créer un utilisateur `terraform`
3. Générer des clés API
4. Assigner les permissions nécessaires

### 3. Configuration des credentials

```bash
# Variables d'environnement (recommandé)
export TF_VAR_opnsense_uri="https://192.168.10.1"
export TF_VAR_opnsense_api_key="your-api-key"
export TF_VAR_opnsense_api_secret="your-api-secret"

# Ou fichier terraform.tfvars (NE PAS COMMITER)
```

## Exemples d'utilisation

### Configurer les interfaces

```
/ops-opnsense configurer interfaces WAN en DHCP et LAN en 192.168.10.1/24
```

### Ajouter des règles firewall

```
/ops-opnsense ajouter règle autorisant HTTP/HTTPS sortant depuis le LAN
```

### Configurer port forwarding

```
/ops-opnsense rediriger le port 443 vers le serveur web 192.168.10.20
```

### Configuration complète

```
/ops-opnsense créer configuration complète pour réseau derrière box Orange
```

## Sécurité

### Règles obligatoires

1. **Anti-lockout**: Toujours inclure une règle permettant l'accès admin
2. **Credentials**: Ne jamais commiter les clés API
3. **Certificats**: Utiliser HTTPS avec certificat valide en production

### Bonnes pratiques

- Principe du moindre privilège
- Logger le trafic bloqué
- Tester en lab avant production
- Sauvegarder avant modifications majeures

## Troubleshooting

### Erreur API

```bash
# Tester la connexion
curl -k -u "api-key:api-secret" \
  "https://<opnsense-ip>/api/core/firmware/status"
```

### Lockout

1. Accès console (Proxmox, local)
2. `pfctl -d` (désactive firewall)
3. Corriger via interface web
4. `pfctl -e` (réactive firewall)

## Agents liés

| Agent | Usage |
|-------|-------|
| `/ops-proxmox` | Provisioning VM OPNsense |
| `/ops-infra-code` | Patterns Terraform généraux |
| `/qa-security` | Audit sécurité configuration |

## Ressources

- [Documentation OPNsense](https://docs.opnsense.org/)
- [Provider Terraform](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs)
- [API OPNsense](https://docs.opnsense.org/development/api.html)

---

YOU MUST toujours inclure une règle anti-lockout dans les configurations firewall.

YOU MUST ne jamais exposer les credentials API dans le code.

YOU MUST valider avec `terraform plan` avant `terraform apply`.

NEVER appliquer des changements firewall sans avoir testé en lab d'abord.

Think hard sur l'impact des règles firewall avant de les proposer.
