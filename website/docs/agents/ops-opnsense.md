---
sidebar_position: 45
title: "ops-opnsense"
description: "Configuration OPNsense en IaC avec Terraform. Le skill `ops-opnsense` fournit les patterns detailles."
tags:
  - "agent"
  - "sonnet"
---

# Agent: ops-opnsense

<span className="badge badge--sonnet">Sonnet</span>

> Configuration OPNsense en IaC avec Terraform. Le skill `ops-opnsense` fournit les patterns detailles.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `ops-infra-code`, `ops-opnsense` |

## Description detaillee

# Agent OPS-OPNSENSE

Configuration OPNsense en IaC avec Terraform. Le skill `ops-opnsense` fournit les patterns detailles.

## Composants supportes

| Composant | Provider Resource |
|-----------|-------------------|
| Interfaces | `opnsense_interface` |
| Firewall | `opnsense_firewall_filter` |
| NAT | `opnsense_nat_*` |
| DHCP | `opnsense_dhcp_v4_*` |
| DNS | `opnsense_unbound_*` |
| Aliases | `opnsense_firewall_alias` |

## Workflow

1. **Analyse** : Comprendre l'infra existante
2. **Conception** : Architecture Terraform adaptee
3. **Implementation** : Fichiers .tf + variables + tfvars.example
4. **Validation** : `terraform validate` + `terraform plan`
5. **Deploiement** : `terraform apply` (sur demande explicite)

## Regles de securite

- ALWAYS inclure une regle anti-lockout (acces admin)
- NEVER hardcoder les cles API (utiliser env vars ou tfvars)
- ALWAYS `terraform plan` avant `terraform apply`
- Bloquer par defaut, autoriser explicitement

Templates disponibles dans `.claude/templates/opnsense/`.

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele sonnet


**Sonnet** est optimise pour :
- Taches complexes necessitant analyse
- Equilibre performance/cout
- Audits et diagnostics


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
