# Fonctionnalites Avancees

## Output Styles

8 modes d'interaction dans `.claude/output-styles/`: `teaching`, `explanatory` (recommande), `concise`, `technical`, `review`, `emoji`, `minimal`, `structured`.

## Templates de Specification

Templates dans `.claude/templates/` pour le workflow Explore → Specify → Plan → Code:

| Template | Utilise par |
|----------|-------------|
| `spec-template.md` | `/work:work-specify` |
| `plan-template.md` | `/work:work-plan` |
| `tasks-template.md` | `/work:work-plan` |

Structure: `specs/[feature]/` contient `spec.md`, `plan.md`, `tasks.md`, `clarifications.md` (opt).

Conventions: `P1`=MVP, `P2`=Important, `P3`=Nice-to-have, `[P]`=parallelisable, `[US1]`=User Story 1.

Templates Proxmox (Terraform) disponibles dans `.claude/templates/proxmox/`.

## Opus 4.6

Adaptive Thinking avec 4 niveaux d'effort (`low`, `medium`, `high`, `max`) - le modele ajuste automatiquement. Fenetre 1M tokens (beta), 128k tokens de sortie, Context Compaction automatique.

## Agent Teams (Experimental)

Coordination parallele d'equipes d'agents. Activation: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` dans `.claude/settings.json`.

Modes: `auto` (defaut), `in-process`, `tmux`. Commande: `/work:work-team "description"`.

Voir `.claude/skills/agent-teams/SKILL.md` pour la documentation complete.

## MCP Configuration

Serveurs MCP dans `.mcp.json` (tous desactives par defaut):

| Server | Usage |
|--------|-------|
| `filesystem` | Acces avance aux fichiers |
| `memory` | Memoire persistante |
| `github` | Integration GitHub |
| `postgres` | Connexion PostgreSQL |
| `puppeteer` | Automatisation navigateur |
| `slack` | Communication equipe |
| `sentry` | Monitoring erreurs |
| `linear` | Gestion de projet |

Pour activer: `"enabled": true` dans `.mcp.json`. Variables d'environnement dans `.env`.

## CLAUDE.md @imports

Syntaxe `@path/to/file` pour importer des fichiers. Chemins relatifs et absolus supportes, imports recursifs (max 5 niveaux). Voir imports charges avec `/memory`.

## Plugins

Distribuer skills, agents, hooks et MCP servers via plugins (`--plugin-dir ./mon-plugin`). Skills namespaces: `/mon-plugin:skill-name`.

## LSP (Language Server Protocol)

Navigation semantique du code via `.lsp.json`. Activation: `export ENABLE_LSP_TOOL=1`.

12 langages supportes (TypeScript, Python, Go, Rust, Java, C/C++, C#, PHP, Kotlin, Ruby, HTML, CSS).

LSP pour: definitions de symboles, references, diagnostics. Grep pour: recherches textuelles.
Voir `.claude/rules/lsp.md` pour les regles detaillees.
