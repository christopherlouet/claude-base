# Backup & Haute Disponibilite — Proxmox

Configuration PBS (Proxmox Backup Server) et ressources HA.

## Backup avec PBS

### Configuration backup schedule

```hcl
resource "proxmox_virtual_environment_cluster_options" "backup" {
  backup_schedule {
    enabled      = true
    schedule     = "0 2 * * *"  # Tous les jours à 2h
    storage      = "pbs-backup"
    mode         = "snapshot"
    compress     = "zstd"
    notification = "failure"

    selection_mode = "include"
    vmid           = [100, 101, 102]
  }
}
```

### Commandes PBS utiles

```bash
# Verifier l'etat des backups
proxmox-backup-client list --repository user@pbs:datastore

# Restaurer un backup
qmrestore pbs:backup/vzdump-qemu-100-2024_01_15-02_00_00.vma 200

# Verifier l'integrite
proxmox-backup-client verify --repository user@pbs:datastore
```

### Bonnes pratiques backup

| Regle | Raison |
|-------|--------|
| Mode `snapshot` | Pas d'arret de VM pendant le backup |
| Compression `zstd` | Meilleur ratio + vitesse que gzip |
| `notification = failure` | Alertes uniquement en cas d'echec |
| Retention policy | Configurer GC + prune dans PBS (pas cote Proxmox) |
| Test de restore | Verifier mensuellement qu'un restore fonctionne |
| Backup offsite | PBS replication vers un second PBS distant |

## Haute disponibilite

### Configuration HA

```hcl
resource "proxmox_virtual_environment_haresource" "critical_vm" {
  resource_id = "vm:100"
  state       = "started"
  group       = "production"

  max_restart  = 3
  max_relocate = 3
}

resource "proxmox_virtual_environment_hagroup" "production" {
  group_id   = "production"
  nodes      = ["pve1", "pve2", "pve3"]
  restricted = true
  nofailback = false
}
```

### Prerequis HA

- Cluster Proxmox >= 3 nodes (quorum)
- Stockage partage (NFS, Ceph, ou ZFS replique)
- Corosync sur reseau dedie recommande
- Fencing configure (iDRAC, IPMI, ou watchdog software)

### Cas d'usage

| Criticite | Configuration |
|-----------|---------------|
| **Mission critical** | HA + storage replique + fencing hardware |
| **Important** | HA + storage partage NFS |
| **Standard** | Pas de HA, backup quotidien + restore < 1h |
| **Dev/Test** | Pas de HA, pas de backup (ephemere) |
