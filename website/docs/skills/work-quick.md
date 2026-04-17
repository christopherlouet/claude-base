---
sidebar_position: 47
title: "work-quick"
description: "Workflow rapide pour changements triviaux (single-file fix, rename, typo). Skip le cycle complet Explore-Plan-TDD-Audit. Declencher quand l'utilisateur veut un fix rapide, un changement simple, ou mentionne \"quick\", \"vite\", \"rapide\"."
tags:
  - "skill"
  - "fork"
---

# Skill: work-quick

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Workflow rapide pour changements triviaux (single-file fix, rename, typo). Skip le cycle complet Explore-Plan-TDD-Audit. Declencher quand l'utilisateur veut un fix rapide, un changement simple, ou mentionne "quick", "vite", "rapide".

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `work`, `quick`, `fix(scope): description` |

## Description detaillee

# Quick Fix Workflow

Mode rapide pour changements triviaux qui ne necessitent pas le cycle complet.

## Criteres d'eligibilite

Ce workflow est reserve aux changements qui remplissent TOUS ces criteres :

| Critere | Seuil |
|---------|-------|
| Fichiers modifies | 1-3 maximum |
| Lignes changees | < 50 lignes |
| Impact | Pas de changement d'API publique |
| Risque | Aucun risque de regression |
| Tests existants | Passent deja (ou pas de tests concernes) |

Exemples eligibles : typo, rename variable, fix import, ajout commentaire, correction CSS, mise a jour version.

Exemples NON eligibles : nouvelle feature, refactoring, correction de bug logique, changement d'interface.

## Workflow (3 etapes)

### 1. SCAN - Verification rapide (30 secondes)

- Lire le fichier cible
- Identifier le changement exact
- Verifier qu'aucun test existant n'est impacte

### 2. FIX - Appliquer le changement

- Modifier le(s) fichier(s)
- Verifier la syntaxe (lint/typecheck si disponible)

### 3. VERIFY - Validation minimale

- Lancer les tests existants : `npm test` / `pytest` / `go test`
- Si les tests passent : OK
- Si les tests echouent : STOP, basculer vers `/dev:dev-tdd`

## Output attendu

```
## Quick Fix Applied

**Changement**: [description]
**Fichier(s)**: [liste]
**Lignes**: [+X / -Y]
**Tests**: PASS ✓

Pret pour commit: `git add [fichiers] && git commit -m "fix(scope): description"`
```

## Garde-fous

- Si le changement depasse les criteres → recommander `/dev:dev-tdd`
- Si les tests echouent → STOP et basculer vers le workflow TDD complet
- JAMAIS de changement d'API publique en mode quick
- JAMAIS de nouveau fichier en mode quick (sauf test)

---

IMPORTANT: Ce mode est un raccourci, pas un contournement. En cas de doute, utiliser le workflow complet.

NEVER utiliser ce mode pour des changements qui impactent la logique metier.

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux work..."_
- _"Je veux quick..."_
- _"Je veux fix(scope): description..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
