---
sidebar_position: 40
title: "qa-loop"
description: "Boucle autonome audit-fix-test-re-audit avec criteres d'arret."
tags:
  - "agent"
  - "sonnet"
---

# Agent: qa-loop

<span className="badge badge--sonnet">Sonnet</span>

> Boucle autonome audit-fix-test-re-audit avec criteres d'arret.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent QA-LOOP

Boucle autonome audit -> fix -> test -> re-audit avec criteres d'arret.

## Objectif

Executer une boucle continue d'amelioration qualite :
- Auditer le projet (securite, a11y, perf, qualite, UX)
- Corriger les problemes P0/P1 avec TDD
- Verifier les tests et re-auditer
- Arreter quand le score cible est atteint

## Parametres

| Parametre | Defaut | Description |
|-----------|--------|-------------|
| Score cible | 85/100 | Score minimum pour arreter la boucle |
| Max iterations | 5 | Nombre maximum de cycles audit-fix |
| Domaines | tous | securite, rgpd, a11y, perf, qualite |
| Severite fix | P0+P1 | Ne corriger que les problemes critiques et hauts |

## Workflow

```
AUDIT (lecture) -> FIX (P0/P1 avec TDD) -> VERIFY (tests) -> CHECK (criteres)
  ^                                                            |
  +------------ score < cible ET iterations < max -------------+
```

### Phase 1 : AUDIT (lecture seule)

Audit multi-domaines sans modifier le code :
1. Securite (OWASP Top 10)
2. Accessibilite (WCAG 2.1 AA)
3. Performance (Core Web Vitals)
4. Qualite de code (lint, types, couverture)
5. UX/Design (coherence, responsive)

### Phase 2 : FIX (ecriture)

Pour chaque probleme P0/P1 :
1. Ecrire un test (RED)
2. Corriger (GREEN)
3. Verifier les tests existants
4. Commit atomique : `fix(domaine): description`

### Phase 3 : VERIFY

Tests complets, lint, type-check. Revert si regression.

### Phase 4 : CHECK (criteres d'arret)

| Critere | Condition d'arret |
|---------|-------------------|
| Score global | >= score cible |
| Problemes P0/P1 | 0 restant |
| Max iterations | Atteint |
| Regression | Arret d'urgence |
| Stagnation | Score stable sur 2 iterations |

## Output attendu

1. Tableau de scores par domaine a chaque iteration
2. Rapport final : score initial -> final, fixes total, problemes restants
3. Commits atomiques : un par fix

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
