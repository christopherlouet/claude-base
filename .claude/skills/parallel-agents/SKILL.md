---
name: parallel-agents
description: Orchestration d'agents paralleles pour maximiser l'efficacite. Declencher quand une tache peut etre decomposee en sous-taches independantes executables en parallele.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
context: fork
---

# Orchestration d'Agents Paralleles

## Objectif

Decomposer les taches complexes en sous-taches independantes et les executer en parallele via des sub-agents specialises pour maximiser l'efficacite.

## Quand utiliser le parallelisme

```
┌──────────────────────────────────────────────────────────────────┐
│                   DECISION: PARALLEL OU SEQUENTIEL ?              │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PARALLELE si:                                                    │
│  - Sous-taches INDEPENDANTES (pas de dependance de donnees)      │
│  - Resultats MERGABLES (combinables sans conflit)                │
│  - Tache DECOMPOSABLE en parties distinctes                      │
│                                                                   │
│  SEQUENTIEL si:                                                   │
│  - Resultat A necessaire pour commencer B                        │
│  - Modifications sur les MEMES fichiers                          │
│  - Ordre d'execution IMPORTANT                                   │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## Patterns de parallelisation

### 1. Fan-Out / Fan-In

```
         ┌─→ [Agent A: audit securite]  ─→┐
         │                                 │
[Tache] ─┼─→ [Agent B: audit perf]     ─→┼─→ [Rapport combine]
         │                                 │
         └─→ [Agent C: audit a11y]     ─→┘
```

**Usage:** Audits, analyses multi-criteres, reviews paralleles

### 2. Map-Reduce

```
[Fichiers] ─→ [Agent 1: fichier A] ─→┐
             → [Agent 2: fichier B] ─→┼─→ [Synthese]
             → [Agent 3: fichier C] ─→┘
```

**Usage:** Analyse de code par module, tests par domaine

### 3. Pipeline avec etapes paralleles

```
[Etape 1] ─→ [Etape 2a] ─→┐
              [Etape 2b] ─→┼─→ [Etape 3]
              [Etape 2c] ─→┘
```

**Usage:** Build pipeline, workflow avec etapes independantes

## Taches parallelisables courantes

### Audits et analyses

| Tache | Agents paralleles | Resultat |
|-------|-------------------|----------|
| Audit complet | `qa-security` + `qa-perf` + `qa-a11y` | Rapport combine |
| Code review | `qa-review` par module/fichier | Liste issues |
| Exploration | `work-explore` par domaine fonctionnel | Map du code |

### Developpement

| Tache | Agents paralleles | Resultat |
|-------|-------------------|----------|
| Tests par module | `dev-test` par service | Suite de tests |
| Documentation | `doc-generate` par composant | Docs completes |
| Migration | `ops-migrate` par dependance | Migration complete |

### Business

| Tache | Agents paralleles | Resultat |
|-------|-------------------|----------|
| Etude de marche | `biz-competitor` + `biz-personas` | Analyse complete |
| Lancement | `growth-landing` + `growth-seo` + `growth-analytics` | Kit lancement |

## Comment dispatcher

### Etape 1: Decomposer la tache

```markdown
## Tache principale: [Description]

### Sous-taches identifiees:
1. [ ] [Sous-tache A] - Agent: [type] - Independante: Oui/Non
2. [ ] [Sous-tache B] - Agent: [type] - Independante: Oui/Non
3. [ ] [Sous-tache C] - Agent: [type] - Independante: Oui/Non

### Dependances:
- A → independant
- B → independant
- C → depend de A et B

### Plan:
- Phase 1 (parallele): A + B
- Phase 2 (sequentiel): C (apres A et B)
```

### Etape 2: Lancer en parallele

Utiliser le tool Task avec plusieurs appels dans un seul message:

```
[Appel 1] Task(subagent_type="qa-security", prompt="Auditer...")
[Appel 2] Task(subagent_type="qa-perf", prompt="Analyser...")
[Appel 3] Task(subagent_type="qa-a11y", prompt="Verifier...")
```

### Etape 3: Combiner les resultats

```markdown
## Rapport combine

### Agent A: [Resultats resumes]
### Agent B: [Resultats resumes]
### Agent C: [Resultats resumes]

### Synthese
[Vue d'ensemble et priorites]
```

## Bonnes pratiques

- Verifier l'independance des sous-taches AVANT de paralleliser
- Donner a chaque agent un scope clair et delimite
- Utiliser `run_in_background: true` pour les taches longues
- Combiner les resultats avec une synthese de haut niveau
- Limiter a 3-5 agents paralleles pour la lisibilite

## Regles

- TOUJOURS verifier les dependances entre sous-taches
- NE JAMAIS paralleliser des modifications sur les memes fichiers
- TOUJOURS fournir un contexte complet a chaque agent
- COMBINER les resultats en un rapport coherent
