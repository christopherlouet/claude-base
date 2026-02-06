---
sidebar_position: 10
title: Fonctionnalites Avancees
description: Opus 4.6, Agent Teams, Plugins, LSP, MCP et fonctionnalites avancees de Claude Code
---

# Fonctionnalites Avancees

> Capacites avancees de Claude Code : Opus 4.6, Agent Teams, Plugins, LSP et plus

## Opus 4.6 : Nouvelles Capacites

Claude Opus 4.6 (`claude-opus-4-6`) apporte des ameliorations majeures pour Claude Code.

### Adaptive Thinking

Remplace le toggle "extended thinking" par 4 niveaux d'effort :

| Niveau | Usage | Cout relatif |
|--------|-------|-------------|
| `low` | Taches simples, reformulations | $ |
| `medium` | Code standard, analyses moderees | $$ |
| `high` | Problemes complexes, audits approfondis | $$$ |
| `max` | Taches critiques, architecture, debugging avance | $$$$ |

Le modele ajuste automatiquement son effort selon la complexite detectee. Il est aussi possible de forcer un niveau via l'API :

```typescript
const response = await anthropic.messages.create({
  model: 'claude-opus-4-6',
  max_tokens: 16384,
  thinking: {
    type: 'enabled',
    budget_tokens: 10000,  // budget pour le raisonnement
    effort: 'high',        // low | medium | high | max
  },
  messages: [{ role: 'user', content: prompt }],
});
```

### Fenetre de contexte 1M tokens (beta)

Opus 4.6 supporte jusqu'a **1 million de tokens** en entree (beta). La tarification standard s'applique jusqu'a 200k tokens, avec une tarification premium au-dela.

| Tranche | Tarification |
|---------|-------------|
| 0 - 200k tokens | Standard |
| 200k - 1M tokens | Premium (tarif majore) |

### 128k tokens de sortie

La limite de sortie passe a **128k tokens** (contre 8k-32k precedemment), permettant la generation de fichiers complets, de documentation extensive, ou de refactorings massifs en une seule reponse.

### Context Compaction

Resume automatiquement le contexte ancien pour maintenir la coherence sur de longues sessions. Particulierement utile avec les sessions paralleles (git worktrees) et les taches complexes multi-fichiers.

## Agent Teams (Experimental)

Coordination parallele d'equipes d'agents sur des taches complexes. Un agent lead orchestre des teammates qui travaillent en parallele avec communication directe entre eux.

> **Activation requise** : Feature experimentale desactivee par defaut.

### Activation

```json
// .claude/settings.json ou .claude/settings.local.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AGENT TEAM                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────┐                                               │
│   │  TEAM LEAD   │ <── Vous interagissez avec le lead            │
│   │  (coordonne) │                                               │
│   └──────┬───────┘                                               │
│          │                                                       │
│          ├──── Shared Task List ────┐                             │
│          │                          │                             │
│    ┌─────┴─────┐  ┌──────────┐  ┌──┴───────┐                    │
│    │ Teammate 1 │  │ Teammate 2│  │ Teammate 3│                   │
│    │ (securite) │  │ (perf)   │  │ (a11y)   │                   │
│    └────────────┘  └──────────┘  └──────────┘                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Modes d'affichage

| Mode | Description | Prerequis |
|------|-------------|-----------|
| `auto` (defaut) | Split-panes si dans tmux, sinon in-process | - |
| `in-process` | Tous les agents dans le terminal principal | Aucun |
| `tmux` | Chaque agent dans son propre pane | tmux installe |

```bash
# Forcer un mode
claude --teammate-mode tmux
```

### Comparaison des approches paralleles

| | Sub-Agents (Task) | Agent Teams | Sessions manuelles (worktrees) |
|---|---|---|---|
| **Communication** | Retour au parent | Messagerie directe | Aucune |
| **Coordination** | Parent gere | Taches partagees | Manuelle |
| **Cout tokens** | Faible | Eleve | Eleve |
| **Ideal pour** | Taches focalisees | Collaboration complexe | Branches independantes |

### Raccourcis clavier

| Raccourci | Action |
|-----------|--------|
| `Shift+Up/Down` | Naviguer entre teammates |
| `Shift+Tab` | Mode delegate (lead = coordination) |
| `Ctrl+T` | Afficher la liste de taches |

### Variables d'environnement

| Variable | Description |
|----------|-------------|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Active la fonctionnalite (valeur: `1`) |
| `CLAUDE_CODE_TASK_LIST_ID` | Partage une task list entre sessions |

### Limitations

- Pas de resume des teammates in-process apres `/resume`
- Un seul team par session
- Pas d'equipes imbriquees
- Split-panes non supporte dans VS Code / Windows Terminal / Ghostty

### Usage dans le socle

Le socle fournit un [skill agent-teams](/docs/skills/agent-teams) et une [commande /work:work-team](/docs/commands/work/work-team) avec des patterns pre-configures :

```bash
# Audit parallele (3 agents: securite, perf, a11y)
/work:work-team "audit complet du projet"

# Feature en equipe (frontend, backend, tests)
/work:work-team "implementer les notifications"

# Debug collaboratif (hypotheses concurrentes)
/work:work-team "investiguer le bug de connexion"
```

## Output Styles

Modes d'interaction personnalises dans `.claude/output-styles/` (8 styles):

| Style | Utilisation | Commande |
|-------|-------------|----------|
| `teaching` | Mode pedagogique avec explications | `/output-style teaching` |
| `explanatory` | Raisonnement detaille, comprendre le pourquoi | `/output-style explanatory` |
| `concise` | Reponses breves et directes | `/output-style concise` |
| `technical` | Details techniques approfondis | `/output-style technical` |
| `review` | Revue de code structuree | `/output-style review` |
| `emoji` | Reponses enrichies d'emojis | `/output-style emoji` |
| `minimal` | Reponses epurees sans decoration | `/output-style minimal` |
| `structured` | Structure ASCII avec separateurs | `/output-style structured` |

Voir la page [Output Styles](/docs/concepts/output-styles) pour la documentation complete.

## Templates de Specification

Templates structures pour le workflow Explore → Specify → Plan → Code dans `.claude/templates/`:

| Template | Description | Utilise par |
|----------|-------------|-------------|
| `spec-template.md` | Specification fonctionnelle avec User Stories | `/work:work-specify` |
| `plan-template.md` | Plan d'implementation technique | `/work:work-plan` |
| `tasks-template.md` | Decoupage en taches par User Story | `/work:work-plan` |

### Structure d'une Specification

```
specs/[feature]/
├── spec.md           # Specification fonctionnelle
├── plan.md           # Plan d'implementation
├── tasks.md          # Decoupage en taches
└── clarifications.md # Historique des clarifications (opt)
```

### Conventions

| Marqueur | Signification |
|----------|---------------|
| `P1` | Priorite MVP (essentiel) |
| `P2` | Priorite Important |
| `P3` | Priorite Nice-to-have |
| `[P]` | Tache parallelisable |
| `[US1]` | Appartient a User Story 1 |
| `EF-XXX` | Exigence Fonctionnelle |
| `CS-XXX` | Critere de Succes |

## MCP Configuration

Configuration centralisee des MCP servers dans `.mcp.json`:

### Serveurs de base

| Server | Usage |
|--------|-------|
| `filesystem` | Acces avance aux fichiers |
| `memory` | Memoire persistante |
| `fetch` | Requetes HTTP externes |
| `github` | Integration GitHub |
| `postgres` | Connexion PostgreSQL |
| `sqlite` | Base SQLite locale |
| `puppeteer` | Automatisation navigateur |
| `sequential-thinking` | Raisonnement structure etape par etape |

### Serveurs recommandes par Boris Cherny

| Server | Usage |
|--------|-------|
| `slack` | Recherche de bugs dans les threads, communication equipe |
| `sentry` | Analyse d'erreurs et monitoring en production |
| `bigquery` | Requetes analytics directes |
| `linear` | Gestion de projet et issues |
| `notion` | Documentation et bases de connaissances |

Pour activer un server: `"enabled": true` dans `.mcp.json`

## CLAUDE.md @imports

Les fichiers CLAUDE.md supportent l'import de fichiers avec la syntaxe `@path/to/file` :

```markdown
# Importer des fichiers dans CLAUDE.md
See @README for project overview and @package.json for npm commands.

# Instructions individuelles (non committees)
@~/.claude/my-project-instructions.md
```

### Regles d'import
- Chemins relatifs et absolus supportes
- Imports recursifs (max 5 niveaux)
- Non evalues dans les blocs de code markdown
- Alternative a CLAUDE.local.md pour les worktrees multiples
- Voir les imports charges avec `/memory`

## Plugins

Systeme de plugins pour distribuer skills, agents, hooks et MCP servers :

### Structure d'un plugin

```
mon-plugin/
├── .claude-plugin/
│   └── plugin.json       # Manifeste (nom, version, description)
├── commands/              # Commandes / skills legacy
├── skills/                # Skills avec SKILL.md
├── agents/                # Sub-agents
├── hooks/
│   └── hooks.json         # Hooks du plugin
├── .mcp.json              # Serveurs MCP
└── .lsp.json              # Serveurs LSP
```

### Utilisation

```bash
# Tester un plugin localement
claude --plugin-dir ./mon-plugin

# Les skills sont namespaces
/mon-plugin:skill-name
```

### Quand utiliser plugins vs standalone

| Approche | Nommage skills | Usage |
|----------|---------------|-------|
| Standalone (`.claude/`) | `/hello` | Personnel, un seul projet |
| Plugin | `/plugin:hello` | Partage equipe, distribution, multi-projets |

## LSP (Language Server Protocol)

Configuration LSP dans `.lsp.json` pour la navigation semantique du code.

### Activation

```bash
export ENABLE_LSP_TOOL=1
```

### Langages supportes (12)

| Langage | Serveur |
|---------|---------|
| TypeScript/JavaScript | `typescript-language-server` |
| Python | `pylsp` |
| Go | `gopls` |
| Rust | `rust-analyzer` |
| Java | `jdtls` |
| C/C++ | `clangd` |
| C# | `omnisharp` |
| PHP | `phpactor` |
| Kotlin | `kotlin-language-server` |
| Ruby | `solargraph` |
| HTML | `vscode-html-language-server` |
| CSS | `vscode-css-language-server` |

### LSP vs Grep

| Besoin | Outil | Pourquoi |
|--------|-------|----------|
| Definition d'un symbole | LSP `goToDefinition` | Resolution semantique |
| Toutes les references | LSP `findReferences` | Usages reels, pas de faux positifs |
| Recherche de texte/pattern | Grep | Plus rapide pour les recherches textuelles |
| Navigation de structure | LSP `documentSymbol` | Arbre des classes/fonctions |
| Erreurs de type | LSP `getDiagnostics` | Diagnostics en temps reel |

---

## Voir aussi

- [Output Styles](/docs/concepts/output-styles) - Styles de formatage
- [Bonnes Pratiques](/docs/guides/best-practices) - Recommandations Boris Cherny
- [Skill agent-teams](/docs/skills/agent-teams) - Documentation Agent Teams
- [Commande /work:work-team](/docs/commands/work/work-team) - Lancement Agent Teams
- [Retour aux concepts](/docs/concepts)
