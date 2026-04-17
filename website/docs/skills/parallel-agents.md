---
sidebar_position: 35
title: "parallel-agents"
description: "Orchestration d'agents paralleles pour maximiser l'efficacite. Declencher quand une tache peut etre decomposee en sous-taches independantes executables en parallele."
tags:
  - "skill"
  - "fork"
---

# Skill: parallel-agents

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Orchestration d'agents paralleles pour maximiser l'efficacite. Declencher quand une tache peut etre decomposee en sous-taches independantes executables en parallele.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Glob`, `Grep`, `Bash` |
| **Mots-cles** | `parallel`, `agents` |

## Description detaillee

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
| Audit complet | `qa-security` + `qa-perf` + `wcag-audit` | Rapport combine |
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
[Appel 3] Task(subagent_type="wcag-audit", prompt="Verifier...")
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

## Prevention des conflits de fichiers

IMPORTANT: Les agents paralleles qui editent les memes fichiers causent des race conditions et des builds casses.

### Avant de paralleliser, etablir une carte des fichiers

```markdown
### Fichiers par agent:
- Agent A: src/auth/ (exclusif)
- Agent B: src/api/ (exclusif)
- Agent C: src/utils/helpers.ts (CONFLIT avec A et B!)

→ Solution: Agent C en sequentiel apres A et B
```

### Regles de file-locking

| Situation | Action |
|-----------|--------|
| 2 agents modifient le meme fichier | SEQUENTIEL obligatoire |
| 2 agents modifient le meme dossier | Verifier les fichiers specifiques |
| Agents en lecture seule (audit) | PARALLELE toujours OK |
| Config partagee (package.json, tsconfig) | SEQUENTIEL pour les edits |

### Fichiers typiquement partages (attention)

- `package.json` — deps ajoutees par plusieurs agents
- `tsconfig.json` — paths modifies
- `src/index.ts` — exports ajoutes
- `.env.example` — variables ajoutees
- Fichiers de routing/navigation

## Bonnes pratiques

- Verifier l'independance des sous-taches AVANT de paralleliser
- Etablir la carte des fichiers modifies par agent AVANT de lancer
- Donner a chaque agent un scope clair et delimite
- Utiliser `run_in_background: true` pour les taches longues
- Combiner les resultats avec une synthese de haut niveau
- Limiter a 3-5 agents paralleles pour la lisibilite
- Preferer `isolation: "worktree"` pour les agents qui editent beaucoup de fichiers

## Agent Teams natif (recommande pour equipes > 2 agents)

Pour les orchestrations complexes necessitant communication inter-agents, preferer **Agent Teams natif** :

| | Sub-Agents (Task) | Agent Teams |
|---|---|---|
| **Communication** | Retour au parent uniquement | Messagerie directe entre agents |
| **Coordination** | Agent principal gere tout | Liste de taches partagee |
| **Cout tokens** | Faible | Eleve (1 contexte par agent) |
| **Ideal pour** | Taches focalisees, resultats combines | Collaboration complexe, debat, consensus |

**Recommandation** : Utiliser les sub-agents Task (ce skill) pour les taches focalisees et independantes. Utiliser Agent Teams (`/work:work-team`) pour les equipes de 3+ agents necessitant discussion et coordination.

Voir le skill `agent-teams` pour la documentation complete.

## Regles

- TOUJOURS verifier les dependances entre sous-taches
- NE JAMAIS paralleliser des modifications sur les memes fichiers
- TOUJOURS etablir la carte des fichiers modifies AVANT de lancer les agents
- TOUJOURS fournir un contexte complet a chaque agent
- COMBINER les resultats en un rapport coherent
- PREFERER `isolation: "worktree"` quand les agents modifient beaucoup de fichiers

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux parallel..."_
- _"Je veux agents..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
