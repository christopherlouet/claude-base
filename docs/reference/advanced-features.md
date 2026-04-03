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
| `high` | `/effort high` | Architecture, audit, refactoring complexe, debug |

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

Adaptive Thinking : Claude ajuste automatiquement la profondeur de son raisonnement selon la complexite de la tache. Remplace `budget_tokens` (deprecie). 3 niveaux d'effort (`low`, `medium`, `high`) pour guider le raisonnement.

Fenetre 1M tokens, 128k tokens de sortie, Context Compaction automatique. Le raisonnement s'intercale entre les appels d'outils (interleaved thinking) pour les workflows agentiques.

## Checkpoint / Rewind

Claude Code sauvegarde automatiquement l'etat du code avant chaque modification (checkpoint). Pour revenir a un etat precedent :

| Methode | Action |
|---------|--------|
| `Esc` × 2 | Annuler la derniere modification et revenir au checkpoint |
| `/rewind` | Choisir un checkpoint specifique dans l'historique |

Recommande en phase Refactor du TDD : si le refactoring casse les tests, `/rewind` est plus rapide qu'un revert git manuel.

## Fast Mode (Research Preview)

Meme modele Opus 4.6, sortie 2.5x plus rapide. Toggle avec `/fast`. Cout premium (voir pricing Anthropic).

| Cas d'usage | Recommandation |
|-------------|----------------|
| Exploration, commits, taches simples | Fast mode adapte |
| Architecture, audit, debug complexe | Mode standard recommande |

## Context Compaction

La compaction resume automatiquement le contexte quand la fenetre approche sa limite. Declenchement manuel avec `/compact`.

| Commande | Effet | Quand utiliser |
|----------|-------|----------------|
| `/compact` | Resume le contexte, conserve l'essentiel | Entre phases longues du workflow |
| `/clear` | Efface tout le contexte | Changement de sujet complet |
| _(auto)_ | Compaction automatique si necessaire | Sessions longues sans action requise |

Hooks associes : `PreCompact` (avant compaction, matcher `manual` ou `auto`) et `PostCompact` (apres). Voir `docs/reference/hooks-reference.md`.

## Claude Code Action (GitHub)

Action officielle Anthropic pour integrer Claude dans les workflows GitHub. Review PRs, repond aux @claude mentions, implemente des changements.

| Scenario | Declencheur | Template |
|----------|------------|----------|
| Review automatique des PRs | `pull_request: opened, synchronize` | `.claude/templates/github-actions/claude-review.yml` |
| Review securite (fichiers critiques) | `pull_request: paths: src/auth/**, src/api/**` | `.claude/templates/github-actions/claude-security-review.yml` |
| Mention @claude | `issue_comment: @claude` | Inclus dans `claude-review.yml` |

Prerequis : une **cle API Anthropic** (pay-per-use) ou un cloud provider (Bedrock, Vertex, Foundry). Le plan Max (OAuth interactif) ne fonctionne pas en CI/CD.

Setup rapide : `/install-github-app` dans Claude Code, ou ajouter `ANTHROPIC_API_KEY` dans les secrets GitHub puis copier le template dans `.github/workflows/`.

Source : [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action)

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

### MCP Channels

Les serveurs MCP peuvent pousser des messages dans une session via `--channels`. Disponible via des plugins channel (Telegram, Discord, iMessage) qui s'installent comme MCP servers.

| Channel | Plugin | Usage |
|---------|--------|-------|
| Telegram | `telegram-channel` | Messages et commandes depuis Telegram |
| Discord | `discord-channel` | Messages depuis un serveur Discord |
| iMessage | `imessage-channel` | Messages depuis iMessage (macOS) |
| Slack | `slack` (MCP natif) | Notifications et messages Slack |

Activation : `claude --channels` au demarrage. Les channels ont acces au filesystem, MCP et git de la session locale.

Permission relay : les channels declarant la capability `permission` peuvent relayer les demandes d'approbation vers votre telephone.

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

Ecosysteme d'extensions communautaires pour Claude Code. Un plugin peut contenir des skills, agents, hooks et MCP servers.

| Action | Commande |
|--------|----------|
| Charger un plugin local | `claude --plugin-dir ./mon-plugin` |
| Skills namespaces | `/mon-plugin:skill-name` |
| Executables plugin | Fichiers dans `bin/` invocables comme commandes Bash |

Les plugins peuvent etre distribues via un repertoire Anthropic-managed. Setting `disableSkillShellExecution` pour desactiver l'execution shell dans les plugins non verifies.

## Scheduled Tasks (Cloud)

Jobs recurrents executes sur l'infrastructure cloud Anthropic. Utile pour les taches operationnelles continues sans session locale active.

| Cas d'usage | Description |
|-------------|-------------|
| PR reviews | Revue automatique des pull requests |
| CI monitoring | Surveillance continue du pipeline CI |
| Dependency audits | Audit periodique des dependances |
| Doc syncing | Synchronisation de documentation |

Configuration via `/tasks` ou l'API. Necessite un plan Pro/Max/Team/Enterprise.

## Computer Use

Integration directe dans Claude Code (Pro/Max). Permet d'ouvrir des fichiers, lancer des outils de dev, cliquer et naviguer dans l'interface sans setup additionnel.

Utile pour: tests visuels, interactions UI, workflows necessitant un navigateur ou un emulateur.

## `/loop` Command

Executer un prompt ou une commande a intervalles reguliers:

```bash
/loop 5m "run tests and report failures"   # toutes les 5 minutes
/loop "check CI status"                     # defaut: toutes les 10 minutes
```

## `/powerup` Command

Lessons interactives et demos animees pour decouvrir les fonctionnalites de Claude Code. Utile pour l'onboarding de nouveaux utilisateurs.

## Variables d'Environnement Avancees

| Variable | Description |
|----------|-------------|
| `CLAUDE_CODE_NO_FLICKER=1` | Rendu alt-screen sans scintillement (virtualized scrollback) |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` | Supprime les credentials des variables d'env des subprocesses |
| `MCP_CONNECTION_NONBLOCKING=true` | Skip l'attente de connexion MCP en mode `-p` (headless/CI) |

## Settings Avances

| Setting | Description |
|---------|-------------|
| `disableSkillShellExecution` | Desactive l'execution shell inline dans les skills, commandes et plugins |
| `managed-settings.d/` | Repertoire drop-in pour policy fragments (Team/Enterprise) |

## LSP (Language Server Protocol)

Navigation semantique du code via `.lsp.json`. Activation: `export ENABLE_LSP_TOOL=1`.

12 langages supportes (TypeScript, Python, Go, Rust, Java, C/C++, C#, PHP, Kotlin, Ruby, HTML, CSS).

LSP pour: definitions de symboles, references, diagnostics. Grep pour: recherches textuelles.
Voir `.claude/rules/lsp.md` pour les regles detaillees.
