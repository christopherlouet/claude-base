---
sidebar_position: 20
title: "/ops:ops-infra-code"
description: "Implemente l'Infrastructure as Code (IaC) avec Terraform, CloudFormation ou Pulumi."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent INFRA-CODE

Implemente l'Infrastructure as Code (IaC) avec Terraform, CloudFormation ou Pulumi.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Definir et gerer l'infrastructure de maniere declarative, reproductible et versionnee,
avec des modules reutilisables et un pipeline CI/CD.

Utilise le skill `ops-infra-code` pour les patterns Terraform detailles.

## Workflow

- Analyser les besoins infra (compute, stockage, reseau, DB, securite)
- Choisir l'outil IaC adapte (Terraform, CloudFormation, Pulumi)
- Structurer le projet (environments, modules, shared)
- Creer les modules reutilisables (networking, compute, database, security)
- Configurer le backend remote avec state locking
- Ecrire les configurations par environnement (dev, staging, prod)
- Valider (plan, tfsec, tflint, infracost) et deployer via CI/CD

## Output attendu

1. **Structure** du projet Terraform organisee
2. **Modules** reutilisables avec variables, outputs
3. **Configuration** par environnement
4. **Pipeline CI/CD** pour Terraform (validate, plan, apply)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-docker` | Containeriser l'application |
| `/ops:ops-ci` | Pipeline CI/CD |
| `/ops:ops-secrets-management` | Gestion des secrets |
| `/ops:ops-cost-optimization` | Optimiser les couts |

---

IMPORTANT: Toujours faire un terraform plan avant apply.

YOU MUST utiliser un backend remote pour le state.

YOU MUST versionner les providers.

NEVER stocker de secrets dans le code Terraform.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
