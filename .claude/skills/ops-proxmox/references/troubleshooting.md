# Troubleshooting — Proxmox

Common issues and diagnostic commands.

## Common issues

| Issue | Cause | Solution |
|-------|-------|----------|
| `TASK ERROR: VM is locked` | Operation in progress | Wait or `qm unlock <vmid>` |
| `storage not found` | Wrong datastore | Check with `pvesm status` |
| `clone failed` | Not enough space | Free up space or change storage |
| `cloud-init drive exists` | cloud-init reapplied | Delete the cloud-init drive before reapply |
| `Permission denied (API)` | Token without permissions | Check ACLs with `pveum acl list` |
| `corosync quorum lost` | Cluster network loss | Check dedicated corosync network |
| `migrate failed` | Incompatible storage | Shared storage required for live migration |
| `agent not running` | qemu-guest-agent missing | Install via cloud-init + `agent: enabled=true` |
| `VMID already in use` | ID conflict | Use `qm list` to find a free ID |
| `boot: no bootable device` | Disk not properly attached | Check boot order in config |

## Diagnostic commands

### Cluster and nodes

```bash
# Cluster state
pvecm status

# Cluster nodes
pvecm nodes

# Quorum
pvecm expected 1   # Force quorum on isolated node (dev only)

# Corosync state
systemctl status corosync
journalctl -u corosync -n 50
```

### VMs and containers

```bash
# List VMs
qm list

# List LXC
pct list

# VM config
qm config <vmid>

# LXC config
pct config <vmid>

# Tasks in progress
pvesh get /cluster/tasks

# Unlock a VM
qm unlock <vmid>

# Force stop a VM
qm stop <vmid> --skiplock --timeout 0
```

### Storage

```bash
# Storage state
pvesm status

# Contents of a storage
pvesm list <storage-id>

# Disk space
pvesm status
df -h

# ZFS derivation
zpool status
zfs list
```

### Network

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
# General logs
journalctl -f

# Proxmox-specific logs
journalctl -u pve-cluster -f
journalctl -u pvedaemon -f
journalctl -u pveproxy -f

# Logs for a specific VM
qm showcmd <vmid>
journalctl -u qemu-server@<vmid>
```

### Terraform

```bash
# Retrieve an existing VM ID from the state
terraform state list | grep vm

# Import an existing VM
terraform import 'module.web.proxmox_virtual_environment_vm.this' 100

# Refresh the state
terraform refresh

# Detailed plan
terraform plan -out=tfplan
terraform show tfplan
```

## Recovery scenarios

### Corrupted VM

1. `qm stop <vmid>` (force if necessary)
2. `qm config <vmid>` to note the config
3. Restore from PBS backup: `qmrestore pbs:backup/... <vmid>`
4. If no backup: boot from rescue ISO and repair

### Node down

1. Check network: `ping <node>`
2. Check IPMI/iDRAC
3. If HA configured: VMs migrate automatically
4. Check cluster quorum: `pvecm status` on another node

### Storage corruption

1. `pvesm status` to identify the affected storage
2. Stop all VMs using it
3. Check integrity: `zpool scrub` (ZFS) or `fsck` (ext4)
4. If unrecoverable: restore from PBS
