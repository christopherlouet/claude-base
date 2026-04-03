---
sidebar_position: 26
title: "/ops:ops-opnsense"
description: "Infrastructure as Code pour OPNsense. Configurer et gerer un pare-feu OPNsense via Terraform."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent OPS-OPNSENSE

Infrastructure as Code pour OPNsense. Configurer et gerer un pare-feu OPNsense via Terraform.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Aider a configurer et gerer OPNsense de maniere declarative avec Terraform,
en utilisant le provider browningluke/opnsense.

Utilise le skill `ops-opnsense` pour les templates et la methodologie detaillee.

## Workflow

- Verifier les prerequis (OPNsense installe, API activee, cles API generees)
- Configurer le provider Terraform avec les credentials
- Implementer la configuration demandee (interfaces, firewall, NAT, services, aliases)
- Valider avec terraform plan avant terraform apply
- Toujours inclure une regle anti-lockout
- Tester en lab avant production

## Output attendu

1. **Configuration Terraform** complete pour OPNsense
2. **Modules** : interfaces, firewall, NAT, services, aliases
3. **Documentation** des regles creees

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-proxmox` | Provisioning VM OPNsense |
| `/ops:ops-infra-code` | Patterns Terraform generaux |
| `/qa:qa-security` | Audit securite configuration |

---

YOU MUST toujours inclure une regle anti-lockout dans les configurations firewall.

YOU MUST ne jamais exposer les credentials API dans le code.

YOU MUST valider avec terraform plan avant terraform apply.

NEVER appliquer des changements firewall sans avoir teste en lab d'abord.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
