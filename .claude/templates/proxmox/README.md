# Templates Terraform Proxmox

Templates pour la gestion d'infrastructure Proxmox VE avec Terraform.

## Fichiers disponibles

| Template | Description | Usage |
|----------|-------------|-------|
| `provider-template.tf` | Configuration du provider bpg/proxmox | Base de tout projet |
| `vm-module-template.tf` | Module VM complète avec cloud-init | `modules/vm/` |
| `lxc-module-template.tf` | Module conteneur LXC | `modules/lxc/` |
| `infrastructure-template.tf` | Infrastructure type complète | Exemple à adapter |

## Structure recommandée

```
infrastructure/
├── proxmox/
│   ├── main.tf                    # Copie de provider-template.tf
│   ├── variables.tf               # Variables globales
│   ├── outputs.tf                 # Outputs globaux
│   ├── terraform.tfvars           # Valeurs (NE PAS COMMITER)
│   ├── modules/
│   │   ├── vm/
│   │   │   ├── main.tf            # Copie de vm-module-template.tf
│   │   │   ├── variables.tf       # (inclus dans le template)
│   │   │   └── outputs.tf         # (inclus dans le template)
│   │   └── lxc/
│   │       ├── main.tf            # Copie de lxc-module-template.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── environments/
│       ├── dev/
│       │   ├── main.tf            # Adapté de infrastructure-template.tf
│       │   └── terraform.tfvars
│       ├── staging/
│       └── prod/
```

## Démarrage rapide

### 1. Préparer le projet

```bash
mkdir -p infrastructure/proxmox/modules/{vm,lxc}
mkdir -p infrastructure/proxmox/environments/{dev,staging,prod}

# Copier les templates
cp .claude/templates/proxmox/provider-template.tf infrastructure/proxmox/main.tf
cp .claude/templates/proxmox/vm-module-template.tf infrastructure/proxmox/modules/vm/main.tf
cp .claude/templates/proxmox/lxc-module-template.tf infrastructure/proxmox/modules/lxc/main.tf
```

### 2. Configurer les credentials

```bash
# Option 1: Fichier terraform.tfvars (gitignore)
cat > infrastructure/proxmox/terraform.tfvars << EOF
proxmox_endpoint  = "https://pve.example.com:8006"
proxmox_api_token = "terraform@pve!token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
proxmox_insecure  = true
EOF

# Option 2: Variables d'environnement
export PROXMOX_VE_ENDPOINT="https://pve.example.com:8006"
export PROXMOX_VE_API_TOKEN="terraform@pve!token=xxx"
```

### 3. Créer un token API Proxmox

```bash
# Sur le node Proxmox
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role PVEVMAdmin
pveum user token add terraform@pve terraform-token --privsep=0
```

### 4. Initialiser et appliquer

```bash
cd infrastructure/proxmox
terraform init
terraform plan
terraform apply
```

## Provider bpg/proxmox

Documentation : https://registry.terraform.io/providers/bpg/proxmox/latest/docs

### Ressources principales

| Ressource | Usage |
|-----------|-------|
| `proxmox_virtual_environment_vm` | Machine virtuelle QEMU/KVM |
| `proxmox_virtual_environment_container` | Conteneur LXC |
| `proxmox_virtual_environment_file` | Fichiers (ISO, templates, snippets) |
| `proxmox_virtual_environment_network_linux_bridge` | Bridge réseau |
| `proxmox_virtual_environment_pool` | Pool de ressources |
| `proxmox_virtual_environment_haresource` | Haute disponibilité |

### Data sources

| Data source | Usage |
|-------------|-------|
| `proxmox_virtual_environment_nodes` | Liste des nodes |
| `proxmox_virtual_environment_datastores` | Datastores disponibles |
| `proxmox_virtual_environment_vms` | VMs existantes |

## Bonnes pratiques

### Sécurité

- Utiliser des tokens API avec permissions minimales
- Ne jamais commiter `terraform.tfvars` avec des secrets
- Utiliser un backend distant avec chiffrement pour le state

### Nommage

| Type | Pattern | Exemple |
|------|---------|---------|
| VM | `{env}-{role}-{index}` | `prod-web-01` |
| LXC | `{env}-{service}-{index}` | `dev-redis-01` |
| VMID | Ranges par env | prod: 200-299, dev: 400-499 |

### Tags

Toujours inclure :
- `environment:{env}` - dev, staging, prod
- `managed-by:terraform`
- `role:{role}` - web, api, db, cache

### State management

```hcl
# Backend S3 (recommandé)
backend "s3" {
  bucket         = "terraform-state"
  key            = "proxmox/${var.environment}/terraform.tfstate"
  region         = "eu-west-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

## Commandes utiles

```bash
# Planifier avec un environnement spécifique
terraform plan -var-file=environments/dev/terraform.tfvars

# Appliquer avec target
terraform apply -target=module.web_servers

# Détruire une ressource
terraform destroy -target=module.web_servers["01"]

# Importer une VM existante
terraform import 'module.legacy.proxmox_virtual_environment_vm.this' 'pve1/qemu/100'

# Refresh le state
terraform refresh
```

## Voir aussi

- Agent `/ops-proxmox` - Assistance à la gestion Proxmox
- Skill `proxmox-infrastructure` - Déclenchement automatique
- Skill `infrastructure-as-code` - Bonnes pratiques Terraform
