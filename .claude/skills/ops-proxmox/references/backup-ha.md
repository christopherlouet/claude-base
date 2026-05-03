# Backup & High Availability — Proxmox

PBS (Proxmox Backup Server) configuration and HA resources.

## Backup with PBS

### Backup schedule configuration

```hcl
resource "proxmox_virtual_environment_cluster_options" "backup" {
  backup_schedule {
    enabled      = true
    schedule     = "0 2 * * *"  # Every day at 2am
    storage      = "pbs-backup"
    mode         = "snapshot"
    compress     = "zstd"
    notification = "failure"

    selection_mode = "include"
    vmid           = [100, 101, 102]
  }
}
```

### Useful PBS commands

```bash
# Check backup status
proxmox-backup-client list --repository user@pbs:datastore

# Restore a backup
qmrestore pbs:backup/vzdump-qemu-100-2024_01_15-02_00_00.vma 200

# Verify integrity
proxmox-backup-client verify --repository user@pbs:datastore
```

### Backup best practices

| Rule | Reason |
|------|--------|
| `snapshot` mode | No VM downtime during backup |
| `zstd` compression | Better ratio + speed than gzip |
| `notification = failure` | Alerts only on failure |
| Retention policy | Configure GC + prune in PBS (not on the Proxmox side) |
| Restore test | Verify monthly that a restore works |
| Offsite backup | PBS replication to a second remote PBS |

## High availability

### HA configuration

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

### HA prerequisites

- Proxmox cluster >= 3 nodes (quorum)
- Shared storage (NFS, Ceph, or replicated ZFS)
- Corosync on a dedicated network recommended
- Fencing configured (iDRAC, IPMI, or software watchdog)

### Use cases

| Criticality | Configuration |
|-------------|---------------|
| **Mission critical** | HA + replicated storage + hardware fencing |
| **Important** | HA + NFS shared storage |
| **Standard** | No HA, daily backup + restore < 1h |
| **Dev/Test** | No HA, no backup (ephemeral) |
