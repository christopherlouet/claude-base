---
sidebar_position: 35
title: "/ops:ops-vps"
description: "Deployment to a VPS server (OVH, Hetzner, DigitalOcean, Scaleway, etc.)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# VPS Agent

Deployment to a VPS server (OVH, Hetzner, DigitalOcean, Scaleway, etc.).

## Request context
`&lt;arguments&gt;`

## Goal

Configure a secure VPS server and deploy an application,
with or without Docker, SSL reverse proxy and CI/CD automation.

## Workflow

- Secure the server (non-root user, SSH key auth, UFW firewall, fail2ban)
- Choose the deployment mode (Docker, PM2/systemd, Gunicorn, Go binary)
- Configure the reverse proxy (Caddy or Nginx) with automatic SSL
- Deploy the application with health checks
- Configure CI/CD (GitHub Actions via SSH or Docker)
- Set up basic monitoring (logs, uptime)
- Optional: automate with Ansible

## Expected output

1. **Script** to secure the server
2. **Configuration** for deployment (docker-compose or PM2/systemd)
3. **Reverse proxy** with SSL (Caddyfile or nginx.conf)
4. **CI/CD pipeline** for automated deployment
5. **Checklist** for security and deployment

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-docker` | Containerize the application |
| `/ops:ops-ci` | CI/CD pipeline |
| `/ops:ops-monitoring` | Monitoring and alerts |
| `/ops:ops-backup` | Backup strategy |

---

IMPORTANT: Always back up before a major update.

IMPORTANT: Test deployments on a staging environment first.

YOU MUST configure automatic backups for data.

NEVER expose services without authentication or firewall.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
