# Troubleshooting — Proxmox

Problemes courants et commandes de diagnostic.

## Problemes courants

| Probleme | Cause | Solution |
|----------|-------|----------|
| `TASK ERROR: VM is locked` | Operation en cours | Attendre ou `qm unlock <vmid>` |
| `storage not found` | Mauvais datastore | Verifier avec `pvesm status` |
| `clone failed` | Pas assez d'espace | Liberer de l'espace ou changer de storage |
| `cloud-init drive exists` | Reapplication cloud-init | Supprimer le drive cloud-init avant reapply |
| `Permission denied (API)` | Token sans permissions | Verifier les ACLs avec `pveum acl list` |
| `corosync quorum lost` | Perte reseau cluster | Verifier reseau corosync dedie |
| `migrate failed` | Stockage incompatible | Stockage partage requis pour live migration |
| `agent not running` | qemu-guest-agent absent | Installer via cloud-init + `agent: enabled=true` |
| `VMID already in use` | Conflit d'ID | Utiliser `qm list` pour trouver un ID libre |
| `boot: no bootable device` | Disque mal attache | Verifier ordre de boot dans config |

## Commandes de diagnostic

### Cluster et nodes

```bash
# Etat du cluster
pvecm status

# Noeuds du cluster
pvecm nodes

# Quorum
pvecm expected 1   # Forcer quorum sur node isole (dev only)

# Etat corosync
systemctl status corosync
journalctl -u corosync -n 50
```

### VMs et conteneurs

```bash
# Lister les VMs
qm list

# Lister les LXC
pct list

# Config d'une VM
qm config <vmid>

# Config d'un LXC
pct config <vmid>

# Tasks en cours
pvesh get /cluster/tasks

# Unlock une VM
qm unlock <vmid>

# Force stop une VM
qm stop <vmid> --skiplock --timeout 0
```

### Storage

```bash
# Etat du stockage
pvesm status

# Contenu d'un storage
pvesm list <storage-id>

# Espace disque
pvesm status
df -h

# Derivation ZFS
zpool status
zfs list
```

### Reseau

```bash
# Bridges
brctl show
ip link show type bridge

# VLANs
cat /proc/net/vlan/config

# Firewall
pve-firewall status
pve-firewall compile
```

### Logs

```bash
# Logs generaux
journalctl -f

# Logs Proxmox specifiques
journalctl -u pve-cluster -f
journalctl -u pvedaemon -f
journalctl -u pveproxy -f

# Logs d'une VM specifique
qm showcmd <vmid>
journalctl -u qemu-server@<vmid>
```

### Terraform

```bash
# Recuperer un VM ID existant dans le state
terraform state list | grep vm

# Importer une VM existante
terraform import 'module.web.proxmox_virtual_environment_vm.this' 100

# Rafraichir le state
terraform refresh

# Plan detaille
terraform plan -out=tfplan
terraform show tfplan
```

## Recovery scenarios

### VM corrompue

1. `qm stop <vmid>` (force si necessaire)
2. `qm config <vmid>` pour noter la config
3. Restaurer depuis backup PBS : `qmrestore pbs:backup/... <vmid>`
4. Si pas de backup : boot depuis ISO rescue et reparer

### Node down

1. Verifier reseau : `ping <node>`
2. Verifier IPMI/iDRAC
3. Si HA configure : les VMs migrent automatiquement
4. Verifier quorum cluster : `pvecm status` sur un autre node

### Corruption storage

1. `pvesm status` pour identifier le storage touche
2. Stopper toutes les VMs qui l'utilisent
3. Verifier integrite : `zpool scrub` (ZFS) ou `fsck` (ext4)
4. Si irrecuperable : restore depuis PBS
