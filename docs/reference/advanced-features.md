# Fonctionnalites Avancees

## Output Styles

10 modes d'interaction dans `.claude/output-styles/`: `teaching`, `explanatory` (recommande), `concise`, `technical`, `review`, `emoji`, `minimal`, `structured`, `debug`, `metrics`.

## Templates de Specification

Templates dans `.claude/templates/` pour le workflow Explore → Specify → Plan → TDD → Audit → Commit:

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

Commande `/effort` pour controler le niveau de raisonnement (slider interactif depuis v2.1.111):

| Niveau | Commande | Cas d'usage |
|--------|----------|-------------|
| `low` | `/effort low` | Exploration, formatage, taches simples |
| `medium` | `/effort medium` | Developpement standard, corrections |
| `high` | `/effort high` | Architecture, audit, refactoring complexe, debug |
| `xhigh` | `/effort xhigh` | Raisonnement maximum — architecture systeme critique, audit securite avance (Opus 4.7 requis) |

Recommandations par workflow du socle:

| Phase | Effort recommande |
|-------|-------------------|
| `/work:work-explore` | low |
| `/work:work-specify`, `/work:work-plan` | high |
| `/dev:dev-tdd` | medium |
| `/qa:qa-audit`, `/qa:qa-security` | high ou xhigh |
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

## Opus 4.7

Adaptive Thinking : Claude ajuste automatiquement la profondeur de son raisonnement selon la complexite de la tache. Remplace `budget_tokens` (deprecie). 4 niveaux d'effort (`low`, `medium`, `high`, `xhigh`) pour guider le raisonnement.

Fenetre 1M tokens, 128k tokens de sortie, Context Compaction automatique. Le raisonnement s'intercale entre les appels d'outils (interleaved thinking) pour les workflows agentiques.

Nouveaute v2.1.111 : `xhigh` debloque le raisonnement maximum d'Opus 4.7. Auto mode disponible pour les abonnes Max (permissions automatiques intelligentes).

## Checkpoint / Rewind

Claude Code sauvegarde automatiquement l'etat du code avant chaque modification (checkpoint). Pour revenir a un etat precedent :

| Methode | Action |
|---------|--------|
| `Esc` × 2 | Annuler la derniere modification et revenir au checkpoint |
| `/rewind` | Choisir un checkpoint specifique dans l'historique |
| `/undo` | Alias de `/rewind` (CLI 2.1.108+) |

Recommande en phase Refactor du TDD : si le refactoring casse les tests, `/rewind` (ou `/undo`) est plus rapide qu'un revert git manuel.

## Session Recap (CLI 2.1.108+)

`/recap` genere un resume structure de la session : decisions prises, fichiers modifies, etat du travail. Configurable dans `/config`.

| Situation | Action |
|-----------|--------|
| Retour apres une pause | `/recap` pour retrouver le contexte |
| Apres `/compact` | `/recap` pour verifier ce qui a ete conserve |
| Session resumee | Recap automatique au resume (si active dans `/config`) |

## Fast Mode (Research Preview)

Meme modele Opus 4.7, sortie 2.5x plus rapide. Toggle avec `/fast`. Cout premium (voir pricing Anthropic).

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

Outil de scan de vulnerabilites utilisant Opus 4.7 pour analyser le code au-dela de l'analyse statique traditionnelle. Raisonne sur les flux de donnees, interactions entre composants et patterns architecturaux.

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

Configuration via `/tasks`, `/schedule` ou l'API. Necessite un plan Pro/Max/Team/Enterprise.

Voir aussi **Routines** (section ci-dessus) pour les workflows automatises plus complexes combinant prompts, repos et connecteurs.

## Computer Use

Integration directe dans Claude Code (Pro/Max). Permet d'ouvrir des fichiers, lancer des outils de dev, cliquer et naviguer dans l'interface sans setup additionnel.

Utile pour: tests visuels, interactions UI, workflows necessitant un navigateur ou un emulateur.

## Routines (CLI 2.1.108+)

Les Routines sont des workflows automatises qui tournent sur l'infrastructure cloud Anthropic. Une routine combine un prompt, un ou plusieurs repos, et des connecteurs en une configuration unique executable sur schedule, via API, ou sur evenement GitHub.

| Propriete | Description |
|-----------|-------------|
| Prompt | Les instructions a executer |
| Repos | Un ou plusieurs repositories cibles |
| Connecteurs | MCP servers, GitHub events, API triggers |
| Execution | Cloud Anthropic — tourne meme laptop eteint |

Cas d'usage avec le socle :

| Routine | Description | Equivalent socle |
|---------|-------------|------------------|
| Review automatique de PRs | Review chaque nouvelle PR | `/qa:qa-review` en version cloud |
| Audit periodique | Audit securite/qualite hebdomadaire | `/qa:qa-audit` en version planifiee |
| Standup automatique | Resume d'activite quotidien | `/ops:ops-standup` en version cloud |
| Dependency check | Audit deps chaque lundi | `/ops:ops-deps` en version planifiee |

Configuration via la console Anthropic ou `/schedule`. Necessite un plan Pro/Max/Team/Enterprise.

## Ultraplan et Ultrareview (CLI 2.1.101+)

Commandes cloud qui delegent le travail a des agents paralleles sur l'infrastructure Anthropic.

| Commande | Description | Quand utiliser |
|----------|-------------|----------------|
| `/ultraplan` | Plan en cloud : draft, revue dans un editeur web, execution remote ou locale | Architecture complexe, plans multi-fichiers |
| `/ultrareview` | Review multi-agent parallele en cloud | Grosses PRs, revues approfondies |

`/ultraplan` cree automatiquement un environnement cloud au premier lancement. Le plan peut etre revise via un editeur web avant execution.

`/ultrareview` lance plusieurs agents en parallele pour une review plus exhaustive que `/qa:qa-review` local. Ideal pour les PRs de plus de 500 lignes.

## TUI Fullscreen (Research Preview, CLI 2.1.89+)

Mode de rendu alternatif qui prend le controle de la surface du terminal comme `vim` ou `htop`. "Fullscreen" refere a la prise en main du drawing surface, **pas** a la maximisation de la fenetre.

Activation : `/tui fullscreen` (CLI 2.1.110+) ou `CLAUDE_CODE_NO_FLICKER=1` avant le lancement. Desactivation : `/tui default`.

### Trois benefices cles

| Benefice | Impact |
|----------|--------|
| Flicker-free | Plus de scintillement dans VS Code terminal, tmux, iTerm2 sur les sessions longues |
| Memoire constante | Seuls les messages visibles dans le render tree → RAM plate meme sur des conversations de plusieurs heures |
| Support souris | Click-to-expand tool results, click URLs/file paths, selection click-and-drag avec copie auto |

Signal visuel : en fullscreen, le prompt input reste **fixe en bas** au lieu de remonter avec l'output.

### Commandes associees

| Mode | Commande | Description |
|------|----------|-------------|
| Fullscreen | `/tui fullscreen` | Active le mode (persiste via le setting `tui`) |
| Default | `/tui default` | Desactive le mode |
| Status | `/tui` | Affiche le renderer actif |
| Focus | `/focus` | Vue condensee : prompt + 1 ligne par outil + reponse finale (separable de `/tui`) |
| Transcript | `Ctrl+O` | Toggle le mode transcript avec navigation `less`-style |

### Navigation en fullscreen

| Raccourci | Action |
|-----------|--------|
| `PgUp` / `PgDn` | Scroll demi-ecran (ou `Fn+↑`/`Fn+↓` sur Mac) |
| `Ctrl+Home` / `Ctrl+End` | Debut / fin de conversation |
| `Ctrl+O` puis `/` | Recherche dans le transcript |
| `Ctrl+O` puis `[` | Dump la conversation dans le scrollback natif du terminal |
| `Ctrl+O` puis `v` | Ouvre le transcript dans `$EDITOR` |

### Variables d'environnement

| Variable | Usage |
|----------|-------|
| `CLAUDE_CODE_NO_FLICKER=1` | Active le fullscreen au demarrage (equivalent au setting `tui`) |
| `CLAUDE_CODE_DISABLE_MOUSE=1` | Garde flicker-free + memoire plate, mais desactive la capture souris (utile en SSH/tmux) |
| `CLAUDE_CODE_SCROLL_SPEED` | Multiplicateur de vitesse molette (1-20, defaut terminal-dependant) |

### Compatibilite tmux

- Requiert `set -g mouse on` dans `~/.tmux.conf` pour la molette
- **Incompatible avec `tmux -CC`** (iTerm2 integration mode)

## Push Notifications (CLI 2.1.110+)

Claude peut envoyer des notifications push sur mobile quand Remote Control est active. Utile pour les taches longues en arriere-plan.

Activation : activer Remote Control + "Push when Claude decides" dans `/config`. Claude notifie en fin de tache ou quand une decision humaine est necessaire.

## `/loop` Command

Executer un prompt ou une commande a intervalles reguliers:

```bash
/loop 5m "run tests and report failures"   # toutes les 5 minutes
/loop "check CI status"                     # auto-pace par Claude (CLI 2.1.101+)
```

Alias : `/proactive` (CLI 2.1.105+). Sans intervalle, Claude auto-determine la frequence optimale.

## `/powerup` Command

Lessons interactives et demos animees pour decouvrir les fonctionnalites de Claude Code. Utile pour l'onboarding de nouveaux utilisateurs.

## `/less-permission-prompts` (CLI 2.1.111+)

Scanne les transcripts de la session et propose des allowlists de permissions optimisees. Reduit le nombre de prompts de permission sans compromettre la securite.

Utile pour : onboarding (generer les permissions initiales), sessions avec trop de prompts, optimisation de la configuration equipe.

## Prompt Caching Avance (CLI 2.1.108+)

| Variable | TTL | Description |
|----------|-----|-------------|
| `ENABLE_PROMPT_CACHING_1H` | 1 heure | Cache prompt etendu pour sessions longues (API key, Bedrock, Vertex, Foundry) |
| `FORCE_PROMPT_CACHING_5M` | 5 minutes | Force le TTL 5 min (utile si telemetrie desactivee) |

Activer dans `.claude/settings.local.json` (non commite) :

```json
{
  "env": {
    "ENABLE_PROMPT_CACHING_1H": "1"
  }
}
```

## Variables d'Environnement Avancees

| Variable | Description |
|----------|-------------|
| `CLAUDE_CODE_NO_FLICKER=1` | Rendu alt-screen sans scintillement (virtualized scrollback) |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` | Supprime les credentials des variables d'env des subprocesses |
| `MCP_CONNECTION_NONBLOCKING=true` | Skip l'attente de connexion MCP en mode `-p` (headless/CI) |
| `ENABLE_PROMPT_CACHING_1H=1` | Cache prompt 1 heure (economies significatives) |
| `FORCE_PROMPT_CACHING_5M=1` | Force cache prompt 5 minutes |

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
