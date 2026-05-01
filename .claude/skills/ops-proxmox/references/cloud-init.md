# Cloud-init — Proxmox

Cloud-config templates and upload via Terraform.

## Cloud-config template

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

## Cloud-init snippet upload

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

## Typical usage

1. Create a base template with cloud-init enabled (once only, manually or via Packer)
2. Clone the template in Terraform with a dynamically generated cloud-config
3. At boot, cloud-init applies: hostname, users, SSH keys, packages, runcmd

## Best practices

- Always include `qemu-guest-agent` (lets Proxmox see the IP and the state)
- `manage_etc_hosts: true` so that `/etc/hosts` matches the hostname
- Prefer SSH keys over passwords
- Never hardcode secrets in the cloud-config (use Vault or post-boot injection)
