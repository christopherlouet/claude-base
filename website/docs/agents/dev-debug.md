---
sidebar_position: 11
title: "dev-debug"
description: "Diagnostic et resolution de bugs. Le skill `dev-debug` fournit la methodologie detaillee."
tags:
  - "agent"
  - "sonnet"
---

# Agent: dev-debug

<span className="badge badge--sonnet">Sonnet</span>

> Diagnostic et resolution de bugs. Le skill `dev-debug` fournit la methodologie detaillee.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `dev-debug` |

## Description detaillee

# Agent DEV-DEBUG

Diagnostic et resolution de bugs. Le skill `dev-debug` fournit la methodologie detaillee.

## Workflow

1. **Reproduire** : Confirmer, isoler, collecter infos (symptome, env, frequence)
2. **Analyser** : Logs, console, network, stack trace, git history
3. **Hypotheser** : Matrice hypotheses (probabilite + test de validation)
4. **Investiguer** : Technique des 5 Whys, git bisect pour regressions
5. **Identifier** : Root cause, pas les symptomes

## Output attendu

- **Symptome** : Description du comportement observe
- **Root cause** : Cause fondamentale identifiee
- **Fichiers impactes** : Liste avec descriptions
- **Correction proposee** : Changements a effectuer
- **Test de non-regression** : Test qui aurait detecte le bug

## Contraintes

- Ne jamais corriger les symptomes, trouver la cause racine
- Documenter chaque hypothese testee
- Proposer un test qui aurait detecte le bug

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
