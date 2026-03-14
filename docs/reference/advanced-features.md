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

### MCP Elicitation (CLI 2.1.76+)

Les serveurs MCP peuvent demander un input structure a l'utilisateur en cours de tache via des dialogues interactifs. Hooks associes: `Elicitation` (demande) et `ElicitationResult` (reponse).

## Async Hooks (CLI 2.1.70+)

Propriete `"async": true` pour executer un hook en arriere-plan sans bloquer la session. Recommande pour les hooks de logging et notification. Les hooks de securite (gitleaks, tests pre-commit) doivent rester synchrones.

| Hook | Mode | Raison |
|------|------|--------|
| SessionStart, PreToolUse, PostToolUse, Setup | **sync** | Actions critiques (securite, formatage) |
| SessionEnd, PreCompact, PostCompact, SubagentStop, Notification | **async** | Logging, pas d'impact sur le workflow |
| TeammateIdle, TaskCompleted, InstructionsLoaded | **async** | Observabilite, non-bloquant |
| Elicitation, ElicitationResult | **async** | Logging MCP |

## HTTP Hooks (CLI 2.1.70+)

Type `"http"` pour envoyer un POST JSON vers une URL externe (webhook). Exemple de configuration webhook generique:

```json
{
  "type": "http",
  "url": "https://your-webhook-url.example.com/hook",
  "headers": { "Authorization": "Bearer ${WEBHOOK_TOKEN}" },
  "timeout": 5000,
  "async": true
}
```

Recommandations: toujours `async: true` et `onFailure: "ignore"` pour eviter de bloquer la session si le service distant est indisponible.

## Claude Code Security (Enterprise/Team)

Outil de scan de vulnerabilites utilisant Opus 4.6 pour analyser le code au-dela de l'analyse statique traditionnelle. Raisonne sur les flux de donnees, interactions entre composants et patterns architecturaux.

Prerequis: plan Enterprise ou Team. Complement de `/qa:qa-security` pour un audit approfondi. Voir [annonce Anthropic](https://www.anthropic.com/news/claude-code-security).

## CLAUDE.md @imports

Syntaxe `@path/to/file` pour importer des fichiers. Chemins relatifs et absolus supportes, imports recursifs (max 5 niveaux). Voir imports charges avec `/memory`.

## Plugins

Distribuer skills, agents, hooks et MCP servers via plugins (`--plugin-dir ./mon-plugin`). Skills namespaces: `/mon-plugin:skill-name`.

## LSP (Language Server Protocol)

Navigation semantique du code via `.lsp.json`. Activation: `export ENABLE_LSP_TOOL=1`.

12 langages supportes (TypeScript, Python, Go, Rust, Java, C/C++, C#, PHP, Kotlin, Ruby, HTML, CSS).

LSP pour: definitions de symboles, references, diagnostics. Grep pour: recherches textuelles.
Voir `.claude/rules/lsp.md` pour les regles detaillees.
