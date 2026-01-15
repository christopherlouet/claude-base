# Architecture de claude-socle

Ce document décrit l'architecture et l'organisation des agents claude-socle.

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────┐
│                    CLAUDE-SOCLE                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    CLAUDE CODE                       │   │
│  │              (CLI Anthropic officiel)                │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   CLAUDE.md                          │   │
│  │            (Configuration projet)                    │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              .claude/commands/                       │   │
│  │                   (Agents)                           │   │
│  │  ┌─────────┬─────────┬─────────┬─────────┐         │   │
│  │  │  work-  │  dev-   │   qa-   │  ops-   │  ...    │   │
│  │  └─────────┴─────────┴─────────┴─────────┘         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Structure des dossiers

```
claude-socle/
├── .claude/
│   └── commands/              # Agents (slash commands)
│       ├── work-*.md          # Workflow général
│       ├── dev-*.md           # Développement
│       ├── qa-*.md            # Qualité
│       ├── ops-*.md           # Opérations
│       ├── doc-*.md           # Documentation
│       ├── biz-*.md           # Business
│       ├── growth-*.md        # Croissance
│       └── legal-*.md         # Légal
│
├── templates/                 # Templates réutilisables
│   ├── CLAUDE.md              # Template configuration
│   ├── CONTRIBUTING.md        # Guide contribution
│   ├── ARCHITECTURE.md        # Ce fichier
│   ├── TROUBLESHOOTING.md     # Dépannage
│   ├── FAQ.md                 # Questions fréquentes
│   └── PERFORMANCE-GUIDE.md   # Guide performance
│
├── CLAUDE.md                  # Configuration projet racine
└── README.md                  # Documentation principale
```

## Catégories d'agents

### Taxonomie

```
┌─────────────────────────────────────────────────────────────┐
│                    CATÉGORIES D'AGENTS                       │
├──────────────┬──────────────────────────────────────────────┤
│ WORK-*       │ Workflow quotidien                           │
│              │ explore, plan, commit, pr                    │
├──────────────┼──────────────────────────────────────────────┤
│ DEV-*        │ Développement                                │
│              │ tdd, debug, refactor, api, testing-setup     │
├──────────────┼──────────────────────────────────────────────┤
│ QA-*         │ Qualité                                      │
│              │ review, automation                           │
├──────────────┼──────────────────────────────────────────────┤
│ OPS-*        │ Opérations                                   │
│              │ ci, monitoring, load-testing, disaster-recovery│
├──────────────┼──────────────────────────────────────────────┤
│ DOC-*        │ Documentation                                │
│              │ api, changelog, fix-issue                    │
├──────────────┼──────────────────────────────────────────────┤
│ BIZ-*        │ Business                                     │
│              │ launch, market, mvp, pricing                 │
├──────────────┼──────────────────────────────────────────────┤
│ GROWTH-*     │ Croissance                                   │
│              │ seo, analytics, landing                      │
├──────────────┼──────────────────────────────────────────────┤
│ LEGAL-*      │ Légal                                        │
│              │ rgpd, cgu, mentions                          │
└──────────────┴──────────────────────────────────────────────┘
```

### Relations entre agents

```
                    ┌─────────────┐
                    │  ONBOARD    │
                    │  (Découverte)│
                    └──────┬──────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────┐
│                    WORKFLOW PRINCIPAL                     │
│                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐           │
│  │ EXPLORE  │───►│   PLAN   │───►│   TDD    │           │
│  └──────────┘    └──────────┘    └────┬─────┘           │
│                                       │                  │
│                                       ▼                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐           │
│  │    PR    │◄───│  COMMIT  │◄───│  REVIEW  │           │
│  └──────────┘    └──────────┘    └──────────┘           │
│                                                          │
└──────────────────────────────────────────────────────────┘
         │                                    │
         ▼                                    ▼
┌─────────────────┐                ┌─────────────────┐
│  AGENTS SUPPORT │                │ AGENTS QUALITÉ  │
│                 │                │                 │
│  - debug        │                │  - security     │
│  - refactor     │                │  - perf         │
│  - api          │                │  - a11y         │
│  - test         │                │  - automation   │
└─────────────────┘                └─────────────────┘
```

## Structure d'un agent

### Format standard

```markdown
# Agent NOM-AGENT

Description courte et claire de l'agent.

## Contexte
$ARGUMENTS                    ← Placeholder OBLIGATOIRE

## Objectif
[Objectif principal de l'agent]

## [Sections spécifiques]
[Contenu adapté à l'agent]

## Checklist
- [ ] Étape 1
- [ ] Étape 2

## Agents liés
| Agent | Usage |
|-------|-------|
| /xxx | Description |

---

IMPORTANT: [Instruction critique]
YOU MUST [Obligation]
NEVER [Interdiction]
Think hard sur [Aspect à considérer]
```

### Éléments requis

| Élément | Obligatoire | Description |
|---------|-------------|-------------|
| `# Agent NAME` | Oui | Titre de l'agent |
| `$ARGUMENTS` | Oui | Placeholder pour les arguments |
| `## Objectif` | Recommandé | But de l'agent |
| `## Checklist` | Recommandé | Étapes à suivre |
| `## Agents liés` | Recommandé | Références croisées |
| Instructions finales | Recommandé | IMPORTANT, YOU MUST, NEVER |

### Conventions de nommage

```
Fichier: .claude/commands/[categorie]-[nom].md

Exemples:
  dev-tdd.md         → /dev-tdd
  ops-ci.md          → /ops-ci
  work-explore.md    → /work-explore
```

## Flux de données

### Invocation d'un agent

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUX D'INVOCATION                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Utilisateur                                                │
│      │                                                      │
│      │  /explore src/auth                           │
│      ▼                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Claude Code                        │   │
│  │  1. Parse la commande                                │   │
│  │  2. Lit .claude/commands/work-explore.md             │   │
│  │  3. Remplace $ARGUMENTS par "src/auth"               │   │
│  │  4. Envoie le prompt à l'API Claude                  │   │
│  └─────────────────────────────────────────────────────┘   │
│      │                                                      │
│      ▼                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   API Claude                         │   │
│  │  - Interprète les instructions                       │   │
│  │  - Exécute les actions (lecture fichiers, etc.)      │   │
│  │  - Génère la réponse                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│      │                                                      │
│      ▼                                                      │
│  Utilisateur (réponse affichée)                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Contexte et héritage

```
┌─────────────────────────────────────────────────────────────┐
│                   HIÉRARCHIE DE CONTEXTE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. CLAUDE.md (racine du projet)                            │
│     └── Conventions, règles globales                        │
│         │                                                   │
│         ▼                                                   │
│  2. Agent (.claude/commands/*.md)                           │
│     └── Instructions spécifiques à la tâche                 │
│         │                                                   │
│         ▼                                                   │
│  3. Arguments ($ARGUMENTS)                                  │
│     └── Contexte spécifique à l'invocation                  │
│         │                                                   │
│         ▼                                                   │
│  4. Historique de conversation                              │
│     └── Contexte des échanges précédents                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Bonnes pratiques

### Design d'agents

| Principe | Description |
|----------|-------------|
| **Single Responsibility** | Un agent = une tâche |
| **Composable** | Les agents peuvent se référencer |
| **Progressive** | Du simple au complexe |
| **Self-documenting** | Instructions claires |

### Anti-patterns

| Anti-pattern | Problème | Solution |
|--------------|----------|----------|
| Agent fourre-tout | Trop de responsabilités | Découper en agents spécialisés |
| Instructions vagues | Résultats incohérents | Être précis et donner des exemples |
| Pas de checklist | Oublis fréquents | Toujours inclure une checklist |
| Isolation | Pas de références | Ajouter "Agents liés" |

## Extension du système

### Ajouter un nouvel agent

1. **Identifier le besoin**
   - Quel problème résout-il ?
   - Existe-t-il déjà un agent similaire ?

2. **Choisir la catégorie**
   - work, dev, qa, ops, doc, biz, growth, legal

3. **Créer le fichier**
   ```bash
   touch .claude/commands/[categorie]-[nom].md
   ```

4. **Suivre le template**
   - Titre, Contexte, Objectif, Instructions, Checklist

5. **Tester**
   - Invoquer avec différents arguments
   - Vérifier la cohérence des résultats

6. **Documenter**
   - Ajouter aux références croisées des agents liés

### Créer une nouvelle catégorie

1. Définir le préfixe (ex: `perf-`)
2. Documenter l'objectif de la catégorie
3. Créer au moins 2-3 agents de la catégorie
4. Mettre à jour CLAUDE.md
5. Ajouter à cette documentation

---

## Versions et évolution

### Versionnement sémantique

```
MAJOR.MINOR.PATCH

MAJOR: Changements incompatibles (structure, conventions)
MINOR: Nouveaux agents, nouvelles catégories
PATCH: Corrections, améliorations mineures
```

### Changelog

Voir `doc-changelog.md` pour le format et les bonnes pratiques de changelog.
