# Fonctionnalites Avancees

## Output Styles

10 modes d'interaction dans `.claude/output-styles/`: `teaching`, `explanatory` (recommande), `concise`, `technical`, `review`, `emoji`, `minimal`, `structured`, `debug`, `metrics`.

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

## Memoire Automatique (CLI 2.1.76+)

Claude Code enregistre et rappelle automatiquement des souvenirs au fil du travail (preferences, decisions, contexte projet). Les souvenirs sont stockes dans `~/.claude/memory/`.

| A memoriser | A mettre dans CLAUDE.md | A mettre dans rules/ |
|-------------|------------------------|---------------------|
| Preferences personnelles | Conventions du projet | Regles par langage/framework |
| Decisions d'architecture | Workflow obligatoire | Patterns de code |
| Contexte equipe | References documentation | Checklist de verification |

Bonnes pratiques:
- Laisser Claude memoriser les preferences et decisions (evite de repeter)
- Garder dans CLAUDE.md ce qui est partage avec l'equipe (versionne dans git)
- Ne pas dupliquer : si c'est dans CLAUDE.md, pas besoin de le memoriser
- Utiliser "remember that..." pour forcer une memorisation explicite

## Effort Levels (CLI 2.1.76+)

Commande `/effort` pour controler le niveau de raisonnement:

| Niveau | Commande | Cas d'usage |
|--------|----------|-------------|
| `low` | `/effort low` | Exploration, formatage, taches simples |
| `medium` | `/effort medium` | Developpement standard, corrections |
| `high` | `/effort high` | Architecture, audit, refactoring complexe |

Recommandations par workflow du socle:

| Phase | Effort recommande |
|-------|-------------------|
| `/work:work-explore` | low |
| `/work:work-specify`, `/work:work-plan` | high |
| `/dev:dev-tdd` | medium |
| `/qa:qa-audit`, `/qa:qa-security` | high |
| `/work:work-commit` | low |

## Sessions Nommees (CLI 2.1.76+)

Flag `--name` / `-n` pour nommer une session au demarrage:

```bash
claude --name "feature-auth"
claude -n "fix-login-bug"
```

Combine avec git worktrees pour des sessions isolees et identifiables:

```bash
git worktree add ../myapp-auth -b feature/auth
cd ../myapp-auth && claude -n "auth-feature"
```

## VSCode URI Handler (CLI 2.1.76+)

Ouvrir un tab Claude Code programmatiquement depuis VSCode:

```
vscode://anthropic.claude-code/open
```

Utile pour: integration CI/CD, scripts de setup, hooks de notification.

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

## RTK - Optimisation Tokens (optionnel)

[RTK](https://github.com/rtk-ai/rtk) (Rust Token Killer) est un proxy CLI qui compresse les sorties de commandes avant qu'elles n'atteignent le contexte LLM. Reduction de 60-90% des tokens consommes.

Installation: `brew install rtk` (ou `cargo install --git https://github.com/rtk-ai/rtk`)

Le socle inclut un hook PreToolUse qui reecrit automatiquement les commandes si RTK est installe:
- `git status` → `rtk git status` (~10 tokens au lieu de ~200)
- `cat file.rs` → `rtk read file.rs` (signatures only en mode agressif)
- `cargo test` → `rtk cargo test` (-90% sur les sorties de test)

Le hook est transparent: si RTK n'est pas installe, rien ne change. Desactiver avec `RTK_DISABLED=1`.

Commandes utiles:
- `rtk gain` : voir les economies de tokens
- `rtk discover` : identifier les commandes non optimisees dans l'historique

## CLAUDE.md @imports

Syntaxe `@path/to/file` pour importer des fichiers. Chemins relatifs et absolus supportes, imports recursifs (max 5 niveaux). Voir imports charges avec `/memory`.

## Plugins

Distribuer skills, agents, hooks et MCP servers via plugins (`--plugin-dir ./mon-plugin`). Skills namespaces: `/mon-plugin:skill-name`.

## LSP (Language Server Protocol)

Navigation semantique du code via `.lsp.json`. Activation: `export ENABLE_LSP_TOOL=1`.

12 langages supportes (TypeScript, Python, Go, Rust, Java, C/C++, C#, PHP, Kotlin, Ruby, HTML, CSS).

LSP pour: definitions de symboles, references, diagnostics. Grep pour: recherches textuelles.
Voir `.claude/rules/lsp.md` pour les regles detaillees.
