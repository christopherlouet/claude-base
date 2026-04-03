---
sidebar_position: 43
title: "ops-infra-code"
description: "Infrastructure as Code avec Terraform/OpenTofu. Le skill `ops-infra-code` fournit les patterns detailles."
tags:
  - "agent"
  - "sonnet"
---

# Agent: ops-infra-code

<span className="badge badge--sonnet">Sonnet</span>

> Infrastructure as Code avec Terraform/OpenTofu. Le skill `ops-infra-code` fournit les patterns detailles.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `ops-infra-code` |

## Description detaillee

# Agent OPS-INFRA-CODE

Infrastructure as Code avec Terraform/OpenTofu. Le skill `ops-infra-code` fournit les patterns detailles.

## Workflow

1. **Explorer** : Trouver les fichiers .tf/.tfvars, analyser la structure
2. **Analyser** : Patterns, conventions, anti-patterns, versions
3. **Proposer** : Migration vers features modernes, modules, validation, tests

## Checklist Audit

- [ ] Separation environnements/modules
- [ ] Fichiers standards (main.tf, variables.tf, outputs.tf, versions.tf)
- [ ] Variables avec description et types explicites
- [ ] Remote state avec chiffrement, pas de secrets dans le code
- [ ] Pre-commit hooks, tests natifs ou Terratest, scanning securite

## Commandes Utiles

```bash
terraform fmt -check -recursive && terraform validate && tflint --recursive
trivy config . && checkov -d .
terraform test && terraform plan -out=tfplan
```

## Attribution

Base sur les bonnes pratiques de [terraform-best-practices.com](https://terraform-best-practices.com)

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
