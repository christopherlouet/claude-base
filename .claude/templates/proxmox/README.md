# Terraform Proxmox Templates

Templates for Proxmox VE infrastructure management with Terraform.

## Available files

| Template | Description | Usage |
|----------|-------------|-------|
| `provider-template.tf` | bpg/proxmox provider configuration | Base for any project |
| `vm-module-template.tf` | Full VM module with cloud-init | `modules/vm/` |
| `lxc-module-template.tf` | LXC container module | `modules/lxc/` |
| `infrastructure-template.tf` | Full sample infrastructure | Example to adapt |

## Recommended structure

```
infrastructure/
├── proxmox/
│   ├── main.tf                    # Copy of provider-template.tf
│   ├── variables.tf               # Global variables
│   ├── outputs.tf                 # Global outputs
│   ├── terraform.tfvars           # Values (DO NOT COMMIT)
│   ├── modules/
│   │   ├── vm/
│   │   │   ├── main.tf            # Copy of vm-module-template.tf
│   │   │   ├── variables.tf       # (included in template)
│   │   │   └── outputs.tf         # (included in template)
│   │   └── lxc/
│   │       ├── main.tf            # Copy of lxc-module-template.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── environments/
│       ├── dev/
│       │   ├── main.tf            # Adapted from infrastructure-template.tf
│       │   └── terraform.tfvars
│       ├── staging/
│       └── prod/
```

## Quick start

### 1. Prepare the project

```bash
mkdir -p infrastructure/proxmox/modules/{vm,lxc}
mkdir -p infrastructure/proxmox/environments/{dev,staging,prod}

# Copy the templates
cp .claude/templates/proxmox/provider-template.tf infrastructure/proxmox/main.tf
cp .claude/templates/proxmox/vm-module-template.tf infrastructure/proxmox/modules/vm/main.tf
cp .claude/templates/proxmox/lxc-module-template.tf infrastructure/proxmox/modules/lxc/main.tf
```

### 2. Configure credentials

```bash
# Option 1: terraform.tfvars file (gitignore)
cat > infrastructure/proxmox/terraform.tfvars << EOF
proxmox_endpoint  = "https://pve.example.com:8006"
proxmox_api_token = "terraform@pve!token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
proxmox_insecure  = true
EOF

# Option 2: Environment variables
export PROXMOX_VE_ENDPOINT="https://pve.example.com:8006"
export PROXMOX_VE_API_TOKEN="terraform@pve!token=xxx"
```

### 3. Create a Proxmox API token

```bash
# On the Proxmox node
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role PVEVMAdmin
pveum user token add terraform@pve terraform-token --privsep=0
```

### 4. Initialize and apply

```bash
cd infrastructure/proxmox
terraform init
terraform plan
terraform apply
```

## bpg/proxmox provider

Documentation: https://registry.terraform.io/providers/bpg/proxmox/latest/docs

### Main resources

| Resource | Usage |
|-----------|-------|
| `proxmox_virtual_environment_vm` | QEMU/KVM virtual machine |
| `proxmox_virtual_environment_container` | LXC container |
| `proxmox_virtual_environment_file` | Files (ISO, templates, snippets) |
| `proxmox_virtual_environment_network_linux_bridge` | Network bridge |
| `proxmox_virtual_environment_pool` | Resource pool |
| `proxmox_virtual_environment_haresource` | High availability |

### Data sources

| Data source | Usage |
|-------------|-------|
| `proxmox_virtual_environment_nodes` | List of nodes |
| `proxmox_virtual_environment_datastores` | Available datastores |
| `proxmox_virtual_environment_vms` | Existing VMs |

## Best practices

### Security

- Use API tokens with minimal permissions
- Never commit `terraform.tfvars` with secrets
- Use a remote backend with encryption for state

### Naming

| Type | Pattern | Example |
|------|---------|---------|
| VM | `{env}-{role}-{index}` | `prod-web-01` |
| LXC | `{env}-{service}-{index}` | `dev-redis-01` |
| VMID | Ranges per env | prod: 200-299, dev: 400-499 |

### Tags

Always include:
- `environment:{env}` - dev, staging, prod
- `managed-by:terraform`
- `role:{role}` - web, api, db, cache

### State management

```hcl
# S3 backend (recommended)
backend "s3" {
  bucket         = "terraform-state"
  key            = "proxmox/${var.environment}/terraform.tfstate"
  region         = "eu-west-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

## Useful commands

```bash
# Plan with a specific environment
terraform plan -var-file=environments/dev/terraform.tfvars

# Apply with target
terraform apply -target=module.web_servers

# Destroy a resource
terraform destroy -target=module.web_servers["01"]

# Import an existing VM
terraform import 'module.legacy.proxmox_virtual_environment_vm.this' 'pve1/qemu/100'

# Refresh the state
terraform refresh
```

## See also

- Agent `/ops:ops-proxmox` - Proxmox management assistance
- Skill `ops-proxmox` - Automatic activation on Proxmox Terraform files
- Skill `ops-infra-code` - Terraform and IaC best practices
