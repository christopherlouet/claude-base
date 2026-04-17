# Cloud-init — Proxmox

Templates cloud-config et upload via Terraform.

## Template cloud-config

```yaml
#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.${domain}
manage_etc_hosts: true

users:
  - name: ${username}
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      ${ssh_keys}

package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - curl
  - vim
  - htop

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
```

## Upload snippet cloud-init

```hcl
resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    data = templatefile("${path.module}/templates/cloud-config.yaml", {
      hostname = var.hostname
      domain   = var.domain
      username = var.username
      ssh_keys = indent(6, join("\n", [for key in var.ssh_keys : "- ${key}"]))
    })
    file_name = "${var.hostname}-cloud-config.yaml"
  }
}
```

## Usage typique

1. Creer un template de base avec cloud-init active (une seule fois, manuellement ou via Packer)
2. Cloner le template dans Terraform avec un cloud-config genere dynamiquement
3. Au boot, cloud-init applique : hostname, users, SSH keys, packages, runcmd

## Bonnes pratiques

- Toujours inclure `qemu-guest-agent` (permet a Proxmox de voir l'IP et l'etat)
- `manage_etc_hosts: true` pour que `/etc/hosts` colle au hostname
- Prefere SSH keys au password
- Ne jamais hardcoder de secrets dans le cloud-config (utiliser Vault ou injection post-boot)
