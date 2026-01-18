---
sidebar_position: 9
title: Templates
description: Comprendre les templates de specification Claude Code
---

# Templates

> Structures predefinies pour le workflow Explore → Specify → Plan → Code

## Qu'est-ce qu'un Template ?

Un **template** est un modele de document structure qui guide la creation de specifications, plans d'implementation et listes de taches. Les templates garantissent une approche coherente et complete pour chaque feature.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  /work-specify                /work-plan                       │
│  ─────────────                ──────────                       │
│        │                           │                           │
│        ▼                           ▼                           │
│  ┌──────────────┐           ┌──────────────┐                   │
│  │ spec.md      │           │ plan.md      │                   │
│  │ (User Stories│    +      │ (Architecture│                   │
│  │  Criteres)   │           │  Phases)     │                   │
│  └──────────────┘           └──────────────┘                   │
│                                    │                           │
│                                    ▼                           │
│                             ┌──────────────┐                   │
│                             │ tasks.md     │                   │
│                             │ (Taches      │                   │
│                             │  detaillees) │                   │
│                             └──────────────┘                   │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Structure des fichiers

Les templates sont dans `.claude/templates/`:

```
.claude/templates/
├── spec-template.md     # Template de specification fonctionnelle
├── plan-template.md     # Template de plan d'implementation
└── tasks-template.md    # Template de decoupage en taches
```

## Les 3 Templates

### 1. spec-template.md - Specification Fonctionnelle

Utilise par `/work-specify` pour creer une specification centree sur la **valeur utilisateur**.

**Contenu principal:**

| Section | Description |
|---------|-------------|
| **Resume** | 1-3 phrases sur la valeur apportee |
| **User Stories** | Stories prioritisees (P1=MVP, P2, P3) |
| **Cas Limites** | Edge cases et scenarios d'erreur |
| **Exigences Fonctionnelles** | EF-001, EF-002... testables |
| **Entites Cles** | Modele de donnees simplifie |
| **Criteres de Succes** | Metriques mesurables |
| **Hors Scope** | Ce qui est explicitement exclu |

**Format User Story:**

```markdown
### US1 - [Titre] (Priorite: P1) MVP

**En tant que** [utilisateur]
**Je veux** [action]
**Afin de** [benefice]

**Criteres d'acceptation**:
1. **Etant donne** [etat], **Quand** [action], **Alors** [resultat]
```

### 2. plan-template.md - Plan d'Implementation

Utilise par `/work-plan` pour definir l'**architecture technique** et les phases.

**Contenu principal:**

| Section | Description |
|---------|-------------|
| **Contexte Technique** | Stack, contraintes, performance |
| **Structure du Projet** | Arborescence des fichiers |
| **Fichiers Impactes** | A creer, a modifier, tests |
| **Approche Choisie** | Architecture + justification |
| **Phases** | Decoupage en phases sequentielles |
| **Risques** | Impact, probabilite, mitigation |

**Format Phase:**

```markdown
### Phase 2 : User Story 1 (P1 - MVP)

**Objectif**: [Reprendre de la spec]

#### Tests (si TDD)
- [ ] T004 - [P] Test unitaire [composant]

#### Implementation
- [ ] T006 - [P] Implementer [modele]
- [ ] T007 - Implementer [service] (depend de T006)

**Checkpoint**: US1 fonctionnelle et testable.
```

### 3. tasks-template.md - Decoupage en Taches

Genere par `/work-plan` pour lister les **taches atomiques** avec dependances.

**Contenu principal:**

| Section | Description |
|---------|-------------|
| **Phase 1: Setup** | Structure et dependances |
| **Phase 2: Fondation** | Infrastructure bloquante |
| **Phase 3+: User Stories** | Taches par story |
| **Phase N: Polish** | Documentation, refactoring |
| **Dependances** | Graphe d'execution |

**Marqueurs:**

| Marqueur | Signification |
|----------|---------------|
| `[P]` | Tache parallelisable |
| `[US1]` | Appartient a User Story 1 |
| `[US2]` | Appartient a User Story 2 |

## Workflow avec Templates

### Commandes associees

```
/work-specify "Ma feature"
      │
      ▼
  Genere: specs/ma-feature/spec.md
      │
      ▼
/work-clarify (optionnel)
      │
      ▼
/work-plan "Ma feature"
      │
      ▼
  Genere: specs/ma-feature/plan.md
          specs/ma-feature/tasks.md
```

### Structure generee

```
specs/[feature]/
├── spec.md           # Specification fonctionnelle
├── plan.md           # Plan d'implementation
├── tasks.md          # Decoupage en taches
└── clarifications.md # Historique des clarifications (optionnel)
```

## Conventions

### Priorites

| Priorite | Signification | Quand utiliser |
|----------|---------------|----------------|
| **P1** | MVP essentiel | Feature minimale viable |
| **P2** | Important | Ameliore significativement l'UX |
| **P3** | Nice-to-have | Peut etre reporte |

### Identifiants

| Prefixe | Type | Exemple |
|---------|------|---------|
| `US` | User Story | US1, US2, US3 |
| `EF` | Exigence Fonctionnelle | EF-001, EF-002 |
| `CS` | Critere de Succes | CS-001, CS-002 |
| `T` | Tache | T001, T002 |

### Parallelisation

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  Taches marquees [P]           Taches sans [P]                 │
│  ──────────────────            ──────────────                  │
│                                                                │
│  Peuvent s'executer            Ont des dependances             │
│  en parallele                  sequentielles                   │
│                                                                │
│  ┌─────┐  ┌─────┐             ┌─────┐                          │
│  │T001 │  │T002 │             │T003 │                          │
│  │ [P] │  │ [P] │             │     │                          │
│  └──┬──┘  └──┬──┘             └──┬──┘                          │
│     │        │                   │                             │
│     └────┬───┘                   ▼                             │
│          │                  ┌─────┐                            │
│          ▼                  │T004 │ (depend de T003)           │
│     [Merge]                 └─────┘                            │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Exemple Complet

### 1. Specification (extrait)

```markdown
# Specification : Authentification Utilisateur

## User Stories

### US1 - Connexion basique (P1) MVP

**En tant que** visiteur
**Je veux** me connecter avec email/mot de passe
**Afin de** acceder a mon compte

**Criteres d'acceptation**:
1. **Etant donne** un utilisateur existant,
   **Quand** il entre ses identifiants valides,
   **Alors** il est redirige vers le dashboard
```

### 2. Plan (extrait)

```markdown
## Fichiers Impactes

### A creer
| Fichier | Responsabilite |
|---------|----------------|
| `src/services/auth.ts` | Service d'authentification |
| `src/components/LoginForm.tsx` | Formulaire de connexion |

### Phase 2 : User Story 1 (P1 - MVP)

- [ ] T004 - [P] [US1] Creer AuthService dans `src/services/auth.ts`
- [ ] T005 - [US1] Implementer LoginForm (depend de T004)
```

### 3. Taches (extrait)

```markdown
## Phase 3 : User Story 1 - Connexion (P1) MVP

### Implementation US1

- [ ] T004 - [P] [US1] Creer AuthService dans `src/services/auth.ts`
- [ ] T005 - [P] [US1] Creer types dans `src/types/auth.ts`
- [ ] T006 - [US1] Implementer LoginForm dans `src/components/LoginForm.tsx`
- [ ] T007 - [US1] Ajouter route `/login` dans `src/routes/index.ts`

**Checkpoint**: US1 fonctionnelle - utilisateur peut se connecter.
```

## Bonnes Pratiques

### Specification (spec.md)

- **Focus valeur utilisateur** : pas de details techniques
- **User stories independantes** : chaque story testable seule
- **Criteres mesurables** : eviter le vague ("rapide", "simple")
- **Maximum 3 clarifications** : faire des choix eclaires sinon

### Plan (plan.md)

- **Justifier les choix** : expliquer pourquoi cette architecture
- **Identifier les risques** : anticiper les problemes
- **Phases claires** : checkpoints a chaque etape

### Taches (tasks.md)

- **Chemins exacts** : inclure le path des fichiers
- **Granularite fine** : 1 tache = 1 commit potentiel
- **Dependances explicites** : utiliser [P] pour parallelisation

## Voir aussi

- [Workflow Explore → Plan → Code](/docs/workflow/explore-plan-code-commit) - Workflow complet
- [/work-specify](/docs/commands/work/work-specify) - Commande de specification
- [/work-plan](/docs/commands/work/work-plan) - Commande de planification
- [/work-clarify](/docs/commands/work/work-clarify) - Clarification des ambiguites
