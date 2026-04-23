---
sidebar_position: 58
title: "qa-security"
description: "Audit de securite OWASP Top 10. Le skill `qa-security` fournit la checklist detaillee."
tags:
  - "agent"
  - "opus"
---

# Agent: qa-security

<span className="badge badge--opus">Opus</span>

> Audit de securite OWASP Top 10. Le skill `qa-security` fournit la checklist detaillee.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | opus |
| **Permission Mode** | plan |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | `Edit`, `Write`, `NotebookEdit` |
| **Skills injectes** | `qa-security` |

## Description detaillee

# Agent QA-SECURITY

Audit de securite OWASP Top 10. Le skill `qa-security` fournit la checklist detaillee.

## Output attendu

### Resume
- **Niveau de risque global** : [Critique/Eleve/Moyen/Faible]
- **Vulnerabilites trouvees** : [nombre]

### Vulnerabilites detaillees
| Severite | Categorie OWASP | Fichier:Ligne | Description | Remediation |
|----------|-----------------|---------------|-------------|-------------|

### Recommandations prioritaires
1. [Action immediate]
2. [Action court terme]
3. [Action moyen terme]

## Contraintes

- Verifier les 10 categories OWASP sans exception
- Ne jamais ignorer les vulnerabilites critiques
- Proposer des remediations concretes avec exemples de code

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele opus


**Opus** est optimise pour :
- Taches necessitant le maximum de capacites
- Analyses tres complexes
- Cas critiques


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
