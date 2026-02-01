---
sidebar_position: 15
title: "/qa:qa-tech-debt"
description: "Identification et priorisation de la dette technique dans le codebase."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# Agent QA-TECH-DEBT

Identification et priorisation de la dette technique dans le codebase.

## Contexte
`&lt;arguments&gt;`

## Categories de Dette Technique

### 1. Dette de Code

| Type | Indicateurs | Priorite |
|------|-------------|----------|
| Code duplique | Blocs &gt; 10 lignes identiques | Haute |
| Fonctions longues | &gt; 50 lignes, &gt; 5 params | Moyenne |
| Classes geantes | &gt; 500 lignes, &gt; 10 methodes publiques | Haute |
| Nesting excessif | &gt; 3 niveaux d'indentation | Moyenne |
| Magic numbers | Valeurs hardcodees sans nom | Basse |

### 2. Dette Architecturale

| Type | Indicateurs | Priorite |
|------|-------------|----------|
| Couplage fort | Imports circulaires, dependances directes | Haute |
| Separation concerns | Business logic dans UI | Haute |
| Patterns obsoletes | Callbacks au lieu de async/await | Moyenne |
| Abstraction manquante | Repetition de patterns | Moyenne |

### 3. Dette de Tests

| Type | Indicateurs | Priorite |
|------|-------------|----------|
| Couverture faible | &lt; 60% sur code critique | Haute |
| Tests fragiles | Tests qui cassent souvent | Haute |
| Mocks excessifs | &gt; 5 mocks par test | Moyenne |
| Tests manquants | Edge cases non couverts | Moyenne |

### 4. Dette de Documentation

| Type | Indicateurs | Priorite |
|------|-------------|----------|
| README obsolete | Ne correspond plus au code | Moyenne |
| API non documentee | Endpoints sans description | Haute |
| Comments outdated | Commentaires qui mentent | Moyenne |

## Patterns a Rechercher

```
# Code smells
TODO|FIXME|HACK|XXX|DEPRECATED
any\s+as\s+any
// eslint-disable
@ts-ignore|@ts-expect-error

# Complexite
if.*if.*if.*if
catch.*catch
\.then\(.*\.then\(.*\.then\(

# Dette tests
skip\(|xit\(|xdescribe\(
test\.only|describe\.only
```

## Matrice de Priorisation

| Impact | Effort Faible | Effort Moyen | Effort Eleve |
|--------|---------------|--------------|--------------|
| **Eleve** | P0 - Immediat | P1 - Sprint | P2 - Quarter |
| **Moyen** | P1 - Sprint | P2 - Quarter | P3 - Backlog |
| **Faible** | P2 - Quarter | P3 - Backlog | P4 - Opportuniste |

## Analyse a Effectuer

### 1. Scan automatique

```bash
# TODOs et FIXMEs
grep -r "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx"

# any TypeScript
grep -r "any" --include="*.ts" --include="*.tsx" | wc -l

# eslint-disable
grep -r "eslint-disable" --include="*.ts" --include="*.tsx"

# ts-ignore
grep -r "@ts-ignore\|@ts-expect-error" --include="*.ts" --include="*.tsx"

# Fichiers longs (> 500 lignes)
find . -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -rn | head -20
```

### 2. Metriques a calculer

| Metrique | Commande/Outil | Seuil Alerte |
|----------|----------------|--------------|
| Complexite cyclomatique | ESLint complexity | &gt; 10 |
| Lignes par fichier | wc -l | &gt; 500 |
| Dependances | Imports count | &gt; 20 |
| Couverture | Jest/Vitest | &lt; 70% |
| TODOs | grep count | &gt; 20 |

### 3. Analyse manuelle

- [ ] Revue des fichiers les plus modifies (git log)
- [ ] Identification des points de friction (dev feedback)
- [ ] Analyse des bugs recurrents (issue tracker)

## Output Attendu

### Resume

```markdown
## Analyse Dette Technique

### Score Global
- **Score de dette**: [1-10] (10 = tres endette)
- **Items critiques (P0-P1)**: [nombre]
- **Effort total estime**: [heures/jours]

### Repartition
| Categorie | Items | Effort |
|-----------|-------|--------|
| Code | [X] | [Y]h |
| Architecture | [X] | [Y]h |
| Tests | [X] | [Y]h |
| Documentation | [X] | [Y]h |
```

### Dette Detaillee

| Priorite | Type | Fichier:Ligne | Description | Effort | Impact |
|----------|------|---------------|-------------|--------|--------|
| P0 | Code | auth.ts:45-120 | Fonction de 75 lignes | 2h | Eleve |
| P0 | Archi | api/* | Imports circulaires | 4h | Eleve |
| P1 | Tests | user.test.ts | Couverture 45% | 3h | Moyen |

### Plan de Remediation

#### Phase 1: Quick Wins (&lt; 1 sprint)
- [ ] Item 1
- [ ] Item 2

#### Phase 2: Refactoring (1-2 sprints)
- [ ] Item 3
- [ ] Item 4

#### Phase 3: Architecture (&gt; 2 sprints)
- [ ] Item 5

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-refactor` | Execution du refactoring |
| `/qa:qa-coverage` | Analyse couverture tests |
| `/qa:qa-review` | Code review approfondie |
| `/work:work-plan` | Planification du refactoring |

---

IMPORTANT: Ne jamais ignorer la dette de securite.

IMPORTANT: Considerer le contexte business (deadline, criticite).

YOU MUST proposer des refactorings incrementaux.

NEVER sous-estimer l'effort de remediation.


---

## Voir aussi

- [Retour aux commandes QA](/docs/commands/qa)
- [Toutes les commandes](/docs/commands)
