---
sidebar_position: 38
title: "qa-tech-debt"
description: "Gestion et priorisation de la dette technique. Declencher quand l'utilisateur veut identifier, prioriser ou planifier le remboursement de la dette technique."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-tech-debt

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Gestion et priorisation de la dette technique. Declencher quand l'utilisateur veut identifier, prioriser ou planifier le remboursement de la dette technique.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Mots-cles** | `tech`, `debt`, `dette technique`, `tech debt`, `refactoring priorite`, `code legacy`, `qualite du code` |

## Description detaillee

# Tech Debt Management

## Declencheurs

- "dette technique"
- "tech debt"
- "refactoring priorite"
- "code legacy"
- "qualite du code"

## Identification

### Code Smells a Detecter

```bash
# TODOs et FIXMEs
grep -r "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" src/

# Fichiers volumineux
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -n | tail -20

# Complexite (nesting)
grep -r "if.*if.*if" --include="*.ts" src/

# any en TypeScript
grep -r ": any" --include="*.ts" --include="*.tsx" src/
```

### Metriques

| Metrique | Seuil | Commande |
|----------|-------|----------|
| LOC/fichier | < 500 | `wc -l` |
| Fonctions/fichier | < 15 | grep |
| Depth nesting | < 4 | analyse |
| Test coverage | > 70% | `npm test -- --coverage` |

## Categorisation

### Impact

| Niveau | Description | Exemples |
|--------|-------------|----------|
| Critique | Bloque le developpement | Couplage circulaire |
| Eleve | Ralentit significativement | Duplication massive |
| Moyen | Gene la maintenance | Nommage confus |
| Faible | Cosmetique | Style inconsistant |

### Effort

| Niveau | Temps | Exemples |
|--------|-------|----------|
| Trivial | < 1h | Renommer variable |
| Faible | < 1 jour | Extraire fonction |
| Moyen | 1-5 jours | Restructurer module |
| Eleve | > 1 semaine | Rewrite composant |

## Priorisation

### Matrice Impact/Effort

```
Impact
  ^
  |  Quick Wins  |  Strategic
  |     (P1)     |    (P2)
  +--------------+-------------
  |   Fill-in    |   Avoid
  |     (P3)     |    (P4)
  +-------------------------> Effort
```

## Plan de Remediation

### Template

```markdown
## Item: [Nom]

**Priorite**: P[1-4]
**Impact**: [Critique/Eleve/Moyen/Faible]
**Effort**: [Trivial/Faible/Moyen/Eleve]

### Description
[Description du probleme]

### Fichiers concernes
- path/to/file.ts:L42

### Solution proposee
[Approche de refactoring]

### Criteres de succes
- [ ] Tests passent
- [ ] Pas de regression
- [ ] Metriques ameliorees
```

## Workflow

1. **Identifier** - Scanner le codebase
2. **Categoriser** - Impact et effort
3. **Prioriser** - Matrice de decision
4. **Planifier** - Integrer au backlog
5. **Executer** - Refactoring incremental
6. **Valider** - Tests et metriques

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux tech..."_
- _"Je veux debt..."_
- _"Je veux dette technique..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Example: Tech Debt Inventory

# Example: Tech Debt Inventory

## Scenario
Audit a 2-year-old Node.js API to inventory and prioritize technical debt.

## Debt Inventory

### Critical (fix within 1 sprint)

| ID | Category | Description | Impact | Effort |
|----|----------|-------------|--------|--------|
| TD-001 | Security | Express 4.17 has known CVEs, upgrade to 4.21+ | High | S |
| TD-002 | Reliability | No error handling middleware; unhandled rejections crash server | High | S |
| TD-003 | Data | Raw SQL queries with string interpolation (SQL injection risk) | High | M |

### High (fix within 1 month)

| ID | Category | Description | Impact | Effort |
|----|----------|-------------|--------|--------|
| TD-004 | Maintainability | 3 god classes > 800 lines (OrderController, UserService, Utils) | Medium | L |
| TD-005 | Testing | Test coverage at 23%, no integration tests | Medium | L |
| TD-006 | Types | 47 `any` types across codebase, no strict mode | Medium | M |
| TD-007 | Dependencies | 12 packages 2+ major versions behind | Medium | M |

### Medium (plan for next quarter)

| ID | Category | Description | Impact | Effort |
|----|----------|-------------|--------|--------|
| TD-008 | Architecture | Circular dependencies between 5 modules | Low | L |
| TD-009 | DX | No linting or formatting configured | Low | S |
| TD-010 | Observability | Console.log only, no structured logging | Low | M |
| TD-011 | API | Inconsistent error response formats across 15 endpoints | Low | M |

## Metrics Summary

```
Total debt items:        11
Critical:                3   (fix immediately)
High:                    4   (plan this month)
Medium:                  4   (next quarter)

Estimated total effort:  ~45 story points
Test coverage:           23% -> target 80%
TypeScript any count:    47 -> target 0
Outdated dependencies:   12 -> target 0
```

## Recommended Paydown Plan

### Sprint 1: Security & Stability
- TD-001: Upgrade Express (1 point)
- TD-002: Add error middleware (2 points)
- TD-003: Parameterized queries (5 points)
- TD-009: Setup ESLint + Prettier (2 points)

### Sprint 2-3: Testing & Types
- TD-006: Enable strict TypeScript, fix `any` types (8 points)
- TD-005: Add tests for critical paths first (13 points)

### Sprint 4+: Architecture
- TD-004: Extract services from god classes (8 points)
- TD-008: Resolve circular dependencies (5 points)

## Key Decisions

- **Security first**: SQL injection and CVEs before any feature work
- **20% rule**: Allocate 20% of each sprint to debt paydown
- **Metrics tracking**: Re-run audit monthly, track trend in coverage and `any` count
- **Boy Scout rule**: Improve any file you touch, even outside debt sprints



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
