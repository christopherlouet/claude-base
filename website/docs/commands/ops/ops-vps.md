---
sidebar_position: 35
title: "/ops:ops-vps"
description: "Deploiement sur serveur VPS (OVH, Hetzner, DigitalOcean, Scaleway, etc.)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent VPS

Deploiement sur serveur VPS (OVH, Hetzner, DigitalOcean, Scaleway, etc.).

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Configurer un serveur VPS securise et deployer une application,
avec ou sans Docker, reverse proxy SSL et automatisation CI/CD.

## Workflow

- Securiser le serveur (utilisateur non-root, SSH par cle, firewall UFW, fail2ban)
- Choisir le mode de deploiement (Docker, PM2/systemd, Gunicorn, binaire Go)
- Configurer le reverse proxy (Caddy ou Nginx) avec SSL automatique
- Deployer l'application avec health checks
- Configurer le CI/CD (GitHub Actions via SSH ou Docker)
- Mettre en place le monitoring basique (logs, uptime)
- Optionnel : automatiser avec Ansible

## Output attendu

1. **Script** de securisation du serveur
2. **Configuration** de deploiement (docker-compose ou PM2/systemd)
3. **Reverse proxy** avec SSL (Caddyfile ou nginx.conf)
4. **Pipeline CI/CD** de deploiement automatise
5. **Checklist** securite et deploiement

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-docker` | Containeriser l'application |
| `/ops:ops-ci` | Pipeline CI/CD |
| `/ops:ops-monitoring` | Monitoring et alertes |
| `/ops:ops-backup` | Strategie de sauvegarde |

---

IMPORTANT: Toujours sauvegarder avant une mise a jour majeure.

IMPORTANT: Tester les deploiements sur un environnement de staging d'abord.

YOU MUST configurer des backups automatiques pour les donnees.

NEVER exposer des services sans authentification ou firewall.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
