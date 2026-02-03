# Fonctionnalités Avancées

## Output Styles (Claude Code 2.1+)

Modes d'interaction personnalisés dans `.claude/output-styles/` (8 styles):

| Style | Utilisation | Commande |
|-------|-------------|----------|
| `teaching` | Mode pédagogique avec explications | `/output-style teaching` |
| `explanatory` | Raisonnement détaillé, comprendre le pourquoi (recommandé par Boris) | `/output-style explanatory` |
| `concise` | Réponses brèves et directes | `/output-style concise` |
| `technical` | Détails techniques approfondis | `/output-style technical` |
| `review` | Revue de code structurée | `/output-style review` |
| `emoji` | Réponses enrichies d'emojis | `/output-style emoji` |
| `minimal` | Réponses épurées sans décoration | `/output-style minimal` |
| `structured` | Structure ASCII avec séparateurs | `/output-style structured` |

Voir `.claude/output-styles/README.md` pour la documentation complète avec exemples.

## Templates de Spécification (inspirés de Spec-Kit)

Templates structurés pour le workflow Explore → Specify → Plan → Code dans `.claude/templates/`:

| Template | Description | Utilisé par |
|----------|-------------|-------------|
| `spec-template.md` | Spécification fonctionnelle avec User Stories | `/work:work-specify` |
| `plan-template.md` | Plan d'implémentation technique | `/work:work-plan` |
| `tasks-template.md` | Découpage en tâches par User Story | `/work:work-plan` |

### Structure d'une Spécification

```
specs/[feature]/
├── spec.md           # Spécification fonctionnelle
├── plan.md           # Plan d'implémentation
├── tasks.md          # Découpage en tâches
└── clarifications.md # Historique des clarifications (opt)
```

### Conventions

| Marqueur | Signification |
|----------|---------------|
| `P1` | Priorité MVP (essentiel) |
| `P2` | Priorité Important |
| `P3` | Priorité Nice-to-have |
| `[P]` | Tâche parallélisable |
| `[US1]` | Appartient à User Story 1 |
| `EF-XXX` | Exigence Fonctionnelle |
| `CS-XXX` | Critère de Succès |

### Workflow Spec-Driven

```
/work:work-explore → /work:work-specify → /work:work-clarify (opt) → /work:work-plan → /dev:dev-tdd
```

### Templates Proxmox (Terraform)

Templates pour la gestion d'infrastructure Proxmox VE dans `.claude/templates/proxmox/`:

| Template | Description |
|----------|-------------|
| `provider-template.tf` | Configuration provider bpg/proxmox |
| `vm-module-template.tf` | Module VM avec cloud-init |
| `lxc-module-template.tf` | Module conteneur LXC |
| `infrastructure-template.tf` | Infrastructure type complète |
| `README.md` | Guide d'utilisation des templates |

## MCP Configuration (Claude Code 2.1+)

Configuration centralisée des MCP servers dans `.mcp.json`:

### Serveurs de base

| Server | Usage | Activé |
|--------|-------|--------|
| `filesystem` | Accès avancé aux fichiers | Non |
| `memory` | Mémoire persistante | Non |
| `fetch` | Requêtes HTTP externes | Non |
| `github` | Intégration GitHub | Non |
| `postgres` | Connexion PostgreSQL | Non |
| `sqlite` | Base SQLite locale | Non |
| `puppeteer` | Automatisation navigateur | Non |
| `sequential-thinking` | Raisonnement structuré étape par étape | Non |

### Serveurs recommandés par Boris Cherny

| Server | Usage | Activé |
|--------|-------|--------|
| `slack` | Recherche de bugs dans les threads, communication équipe | Non |
| `sentry` | Analyse d'erreurs et monitoring en production | Non |
| `bigquery` | Requêtes analytics directes (élimine l'écriture SQL manuelle) | Non |
| `linear` | Gestion de projet et issues | Non |
| `notion` | Documentation et bases de connaissances | Non |

Pour activer un server: `"enabled": true` dans `.mcp.json`

### Configuration des variables d'environnement

Créez un fichier `.env` avec les tokens nécessaires :

```bash
# GitHub
GITHUB_TOKEN=ghp_xxxxx

# Slack
SLACK_BOT_TOKEN=xoxb-xxxxx
SLACK_TEAM_ID=T0123456789

# Sentry
SENTRY_AUTH_TOKEN=sntrys_xxxxx
SENTRY_ORG=my-org

# BigQuery
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
BIGQUERY_PROJECT_ID=my-project

# Linear
LINEAR_API_KEY=lin_api_xxxxx

# Notion
NOTION_API_KEY=secret_xxxxx
```

## CLAUDE.md @imports

Les fichiers CLAUDE.md supportent l'import de fichiers avec la syntaxe `@path/to/file` :

```markdown
# Importer des fichiers dans CLAUDE.md
See @README for project overview and @package.json for npm commands.

# Instructions individuelles (non committées)
@~/.claude/my-project-instructions.md
```

### Règles d'import
- Chemins relatifs et absolus supportés
- Imports récursifs (max 5 niveaux)
- Non évalués dans les blocs de code markdown
- Alternative à CLAUDE.local.md pour les worktrees multiples
- Voir les imports chargés avec `/memory`

## Plugins (Claude Code 2.1+)

Système de plugins pour distribuer skills, agents, hooks et MCP servers :

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

# Les skills sont namespacés
/mon-plugin:skill-name
```

### Quand utiliser plugins vs standalone
| Approche | Nommage skills | Usage |
|----------|---------------|-------|
| Standalone (`.claude/`) | `/hello` | Personnel, un seul projet |
| Plugin | `/plugin:hello` | Partage équipe, distribution, multi-projets |

## LSP (Language Server Protocol)

Configuration LSP dans `.lsp.json` pour la navigation sémantique du code.

### Activation

```bash
export ENABLE_LSP_TOOL=1
```

### Langages supportés (12)

| Langage | Serveur | Extensions |
|---------|---------|------------|
| TypeScript/JavaScript | `typescript-language-server` | `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs` |
| Python | `pylsp` | `.py`, `.pyi` |
| Go | `gopls` | `.go` |
| Rust | `rust-analyzer` | `.rs` |
| Java | `jdtls` | `.java` |
| C/C++ | `clangd` | `.c`, `.cpp`, `.h`, `.hpp` |
| C# | `omnisharp` | `.cs` |
| PHP | `phpactor` | `.php` |
| Kotlin | `kotlin-language-server` | `.kt`, `.kts` |
| Ruby | `solargraph` | `.rb` |
| HTML | `vscode-html-language-server` | `.html`, `.htm` |
| CSS | `vscode-css-language-server` | `.css`, `.scss`, `.less` |

### LSP vs Grep

| Besoin | Outil | Pourquoi |
|--------|-------|----------|
| Définition d'un symbole | LSP `goToDefinition` | Résolution sémantique (imports, héritage) |
| Toutes les références | LSP `findReferences` | Trouve les usages réels, pas les faux positifs |
| Recherche de texte/pattern | Grep | Plus rapide pour les recherches textuelles |
| Navigation de structure | LSP `documentSymbol` | Arbre des classes/fonctions |
| Erreurs de type | LSP `getDiagnostics` | Diagnostics en temps réel |

Voir `.claude/rules/lsp.md` pour les règles détaillées.
