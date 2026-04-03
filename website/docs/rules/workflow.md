---
sidebar_position: 26
title: "workflow"
description: "Avant de commencer a travailler sur un projet existant :"
tags:
  - "rule"
  - "workflow"
---

# Regles: workflow

> Avant de commencer a travailler sur un projet existant :

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

_Toutes les fichiers_

## Regles detaillees

# Workflow Rules

## Choix du Workflow

| Complexite | Workflow | Commande |
|------------|----------|----------|
| Trivial (typo, rename, 1-3 fichiers) | Quick | `/work:work-quick` |
| Standard (feature, bugfix) | Complet | Explore → Plan → TDD → Audit → Commit |
| Batch (backlog de stories) | Batch | `/work:work-batch "prd.json"` |

## Cycle Obligatoire: Explore -&gt; Plan -&gt; TDD -&gt; Audit -&gt; Commit

### 0. CI BASELINE (recommande)

Avant de commencer a travailler sur un projet existant :

- Lancer lint, type-check et tests pour connaitre l'etat CI actuel
- Noter les erreurs PRE-EXISTANTES pour ne pas les confondre avec les nouvelles
- Si CI est deja en echec, le signaler a l'utilisateur avant de commencer

### 1. EXPLORE (obligatoire)

- Lire et comprendre le code existant AVANT de modifier
- Identifier les patterns et conventions en place
- NE JAMAIS coder sans avoir explore
- Utiliser `/work:work-explore` ou l'agent `work-explore`

### 2. PLAN (obligatoire pour features complexes)

- Proposer une architecture AVANT d'implementer
- Lister les fichiers a creer/modifier
- Identifier les risques potentiels
- Attendre validation avant de coder
- Utiliser `/work:work-plan`

### 3. TDD (obligatoire)

- IMPORTANT: Toujours ecrire les tests AVANT le code
- Cycle Red-Green-Refactor obligatoire:
  1. RED: Ecrire un test qui echoue
  2. GREEN: Ecrire le code minimal pour passer le test
  3. REFACTOR: Ameliorer le code sans casser les tests (si ca casse → `/rewind` pour revenir au dernier etat stable)
- Utiliser `/dev:dev-tdd` pour le cycle complet
- Commits atomiques et frequents
- Respecter les conventions du projet
- Couverture minimum 80% sur nouveau code

### 4. AUDIT (adaptatif selon criticite)

Audit qualite apres TDD, avec correction en boucle jusqu'au score cible de 90.

| Type de changement | Niveau d'audit | Commande |
|-------------------|----------------|----------|
| Critique (auth, paiement, donnees sensibles) | Audit complet + fix en boucle | `/qa:qa-loop "score 90"` |
| Feature UI/UX | Design + accessibilite | `/qa:qa-design` + `/qa:wcag-audit` |
| Feature standard | Review + fix en boucle | `/qa:qa-loop "score 90"` |
| Bugfix simple | Review rapide | `/qa:qa-review` |

- IMPORTANT: Ne pas commiter sans avoir atteint le score cible (90)
- Le TDD valide le comportement, l'audit valide la qualite globale (securite, perf, a11y)
- Si le score est insuffisant, corriger et re-auditer en boucle
- Utiliser `/qa:qa-loop "score 90"` par defaut

### 5. COMMIT

- Message de commit descriptif (Conventional Commits)
- Referencer les issues si applicable
- PR avec description complete
- Utiliser `/work:work-commit` ou `/work:work-pr`

## Gestion du scope

Les sessions avec un scope trop large (15+ taches) generent systematiquement des regressions. Preferer des sessions focalisees :

| Scope | Approche recommandee |
|-------|---------------------|
| 1-5 taches | Session unique, workflow standard |
| 6-10 taches | Decouper en 2-3 commits logiques |
| 10-15 taches | Decouper en sessions separees par domaine |
| 15+ taches | STOP — decouper en features independantes, une PR par feature |

Signaux d'alerte :
- Plus de 10 fichiers modifies sans commit intermediaire → commiter maintenant
- Un fix introduit une regression → revert, commiter ce qui marche, traiter le reste separement
- Le scope grossit pendant le travail → s'arreter, commiter l'etat stable, replanifier

## Gestion du contexte

| Situation | Action | Commande |
|-----------|--------|----------|
| Entre Explore et Plan | Compacter si exploration longue | `/compact` |
| Entre Plan et TDD | Compacter si plan detaille | `/compact` |
| Entre TDD et Audit | Compacter si TDD long | `/compact` |
| Changement de sujet complet | Effacer le contexte | `/clear` |
| Session normale | Laisser l'auto-compaction gerer | _(rien)_ |
| Refactoring casse tout | Revenir au dernier etat stable | `/rewind` |

Preferer `/compact` a `/clear` : la compaction conserve l'essentiel du contexte (decisions, conventions apprises) alors que `/clear` efface tout.

## Anti-patterns a Eviter

- Coder sans comprendre l'existant
- Implementer sans plan valide
- Coder AVANT d'ecrire les tests (violer TDD)
- Commiter sans audit (sauter la phase Audit)
- Commits geants multi-fonctionnalites
- Tests avec trop de mocks
- `any` partout en TypeScript
- Copier-coller sans adapter
- Optimiser prematurement
- Ignorer les warnings de lint/types
- Sessions trop ambitieuses (15+ taches dans une session)
- Confondre erreurs CI pre-existantes et nouvelles erreurs

## Workflows Recommandes

### Nouvelle feature
```
/work:work-flow-feature "description"
# ou manuellement (TDD obligatoire):
/work:work-explore -> /work:work-plan -> /dev:dev-tdd -> /qa:qa-loop "score 90" -> /work:work-pr
```

### Correction de bug
```
/work:work-flow-bugfix "description du bug"
```

### Nouvelle release
```
/work:work-flow-release "v2.0.0"
```

### Audit complet
```
/qa:qa-audit  # Securite + RGPD + A11y + Perf (lecture seule)
```

### Audit + fix en boucle
```
/qa:qa-loop                  # Audit + fix P0/P1 jusqu'a score 90 (defaut)
/qa:qa-loop "score 95"       # Score cible personnalise
```

### Deploiement securise
```
/ops:ops-deploy              # Checklist pre-deploy + deploy + post-deploy
```

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
